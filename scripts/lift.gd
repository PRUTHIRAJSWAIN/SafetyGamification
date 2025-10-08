extends Node2D

enum DOOR_STATE { OPEN, OPENING, CLOSING, CLOSED }
enum LIFT_STATE { IDLE, MOVING }

@onready var door_body: Node2D = $DoorBody as Node2D
@onready var door_area: Area2D = $DoorArea as Area2D
@onready var door_action_timer: Timer = $DoorActionTimer as Timer

var door_scale_max: float = 1.0
var door_scale_min: float = 0.235
var door_speed: float = 1.0
var door_status: DOOR_STATE = DOOR_STATE.OPEN

var total_floors: int = 4
var lift_status: LIFT_STATE = LIFT_STATE.IDLE

var target_floor_queue: Array[int] = []   # queue of unique floor IDs
var current_floor: int = 0
var next_floor: int = -1

var lift_movement_speed: float = 100.0
var floor_offset: float = -256.0
var base_y: float = -103
const ARRIVE_EPS: float = 1.0

func _ready() -> void:
	base_y = position.y
	door_action_timer.one_shot = true

func _process(delta: float) -> void:
	# print(position)  # comment out if too noisy
	match door_status:
		DOOR_STATE.OPENING:
			var new_y: float = move_toward(door_body.scale.y, door_scale_min, door_speed * delta)
			door_body.scale.y = new_y
			if is_equal_approx(new_y, door_scale_min):
				door_status = DOOR_STATE.OPEN
				if door_area.get_overlapping_bodies().is_empty():
					door_action_timer.start()

		DOOR_STATE.CLOSING:
			var new_y: float = move_toward(door_body.scale.y, door_scale_max, door_speed * delta)
			door_body.scale.y = new_y
			if is_equal_approx(new_y, door_scale_max):
				door_status = DOOR_STATE.CLOSED
				if next_floor != -1:
					lift_status = LIFT_STATE.MOVING

		DOOR_STATE.CLOSED:
			if next_floor != -1:
				var target_floor_location: Vector2 = Vector2(position.x, floor_to_y(next_floor))
				position = position.move_toward(target_floor_location, delta * lift_movement_speed)
				if position.distance_to(target_floor_location) < ARRIVE_EPS:
					position = target_floor_location
					_arrived_at_floor(next_floor)

		_:
			pass

func floor_to_y(floor: int) -> float:
	return base_y + float(floor) * floor_offset

# ---------------- Queue / movement helpers ----------------

func _arrived_at_floor(floor: int) -> void:
	current_floor = floor
	target_floor_queue.erase(floor)  # clear served request
	door_status = DOOR_STATE.OPENING
	lift_status = LIFT_STATE.IDLE
	update_next_floor()

func update_next_floor() -> void:
	if target_floor_queue.is_empty():
		next_floor = -1
		return

	# Pick nearest to current_floor (simple heuristic)
	var best: int = target_floor_queue[0]
	var best_d: int = abs(best - current_floor)
	for f in target_floor_queue:
		var d: int = abs(f - current_floor)
		if d < best_d:
			best = f
			best_d = d
	next_floor = best

func _on_door_action_timer_timeout() -> void:
	if door_area.has_overlapping_bodies():
		# Someone still in the doorway; try again
		door_action_timer.start()
	else:
		door_status = DOOR_STATE.CLOSING

func _on_door_area_body_entered(body: Node2D) -> void:
	if door_status == DOOR_STATE.CLOSING:
		door_status = DOOR_STATE.OPENING
	elif door_status == DOOR_STATE.CLOSED:
		push_error("Object entered when door closed!")

func _on_door_area_body_exited(body: Node2D) -> void:
	if door_status == DOOR_STATE.OPEN and door_area.get_overlapping_bodies().is_empty():
		door_action_timer.start()

func add_floor_to_queue(floor_id: int) -> void:
	if floor_id < 0 or floor_id >= total_floors:
		push_error("Floor ID passed is more than available floors: %s" % floor_id)
		return

	if not target_floor_queue.has(floor_id):
		target_floor_queue.append(floor_id)

	# If we don't have a target yet, plan one and ensure doors will close to start moving
	if next_floor == -1:
		update_next_floor()
		if door_status == DOOR_STATE.OPEN and door_area.get_overlapping_bodies().is_empty():
			door_action_timer.start()

# Buttons
func _on_ground_pressed() -> void:
	add_floor_to_queue(0)

func _on_first_floor_pressed() -> void:
	add_floor_to_queue(1)

func _on_second_floor_pressed() -> void:
	add_floor_to_queue(2)

func _on_third_floor_pressed() -> void:
	add_floor_to_queue(3)


func _on_open_pressed() -> void:
	if next_floor == -1:
		if door_status == DOOR_STATE.CLOSED or door_status == DOOR_STATE.CLOSING:
			door_status = DOOR_STATE.OPENING
