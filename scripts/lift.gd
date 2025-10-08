extends Node2D

# ---------------- ENUMS ----------------
enum DOOR_STATE { OPEN, OPENING, CLOSING, CLOSED }
enum LIFT_STATE { IDLE, MOVING }

# ---------------- NODES ----------------
@onready var door_body: Node2D = $DoorBody as Node2D
@onready var door_area: Area2D = $DoorArea as Area2D
@onready var door_action_timer: Timer = $DoorActionTimer as Timer

# ---------------- DOOR SETTINGS ----------------
var door_scale_max: float = 1.0
var door_scale_min: float = 0.235
var door_speed: float = 1.0
var door_status: DOOR_STATE = DOOR_STATE.CLOSED

# ---------------- LIFT SETTINGS ----------------
@export var total_floors: int = 4
@export var floor_offset: float = -256.0
var lift_status: LIFT_STATE = LIFT_STATE.IDLE
var lift_movement_speed: float = 100.0
var base_y: float = -103
const ARRIVE_EPS: float = 1.0

# ---------------- QUEUE DATA ----------------
var target_floor_queue: Array[int] = []
var current_floor: int = 0
var next_floor: int = -1
var lift_direction: int = 0  # -1 = down, 1 = up, 0 = idle

# ---------------- READY ----------------
func _ready() -> void:
	base_y = position.y
	door_action_timer.one_shot = true

# ---------------- PROCESS ----------------
func _process(delta: float) -> void:
	
	match door_status:
		DOOR_STATE.OPENING:
			var new_y: float = move_toward(door_body.scale.y, door_scale_min, door_speed * delta)
			door_body.scale.y = new_y
			if is_equal_approx(new_y, door_scale_min):
				door_status = DOOR_STATE.OPEN

		DOOR_STATE.CLOSING:
			var new_y: float = move_toward(door_body.scale.y, door_scale_max, door_speed * delta)
			door_body.scale.y = new_y
			if is_equal_approx(new_y, door_scale_max):
				door_status = DOOR_STATE.CLOSED
				if next_floor != -1:           #useless
					lift_status = LIFT_STATE.MOVING #useless

		DOOR_STATE.CLOSED:
			if next_floor != -1:
				var target_floor_location: Vector2 = Vector2(position.x, floor_to_y(next_floor))
				position = position.move_toward(target_floor_location, delta * lift_movement_speed)
				current_floor = y_to_floor(position.y)
				if position.distance_to(target_floor_location) < ARRIVE_EPS:
					position = target_floor_location
					_arrived_at_floor(next_floor)
					
		DOOR_STATE.OPEN:
			if door_area.get_overlapping_bodies().is_empty() and door_action_timer.is_stopped():
					door_action_timer.start()
		_:
			pass

# ---------------- UTILITIES ----------------
func floor_to_y(floor_id: int) -> float:
	return base_y + float(floor_id) * floor_offset

func y_to_floor(height:float) -> int:
	return int(( height - base_y ) / floor_offset)

# ---------------- ARRIVAL ----------------
func _arrived_at_floor(floor_id: int) -> void:
	current_floor = floor_id
	target_floor_queue.erase(floor_id)
	lift_status = LIFT_STATE.IDLE
	door_status = DOOR_STATE.OPENING
	update_next_floor()

# ---------------- QUEUE MANAGEMENT ----------------
func update_next_floor() -> void:
	if target_floor_queue.is_empty():
		next_floor = -1
		lift_direction = 0
		return

	# Determine lift direction if idle
	if lift_direction == 0 and next_floor == -1:
		if target_floor_queue[0] > current_floor:
			lift_direction = 1
		elif target_floor_queue[0] < current_floor:
			lift_direction = -1

	# -------- NEW LOGIC: handle intermediate floors in same direction --------
	# Find floors in current direction that are ahead of us (between current and next)
	var possible_floors: Array[int] = []
	for f in target_floor_queue:
		if lift_direction == 1 and f > current_floor:
			possible_floors.append(f)
		elif lift_direction == -1 and f < current_floor:
			possible_floors.append(f)

	# If none found, reverse direction
	if possible_floors.is_empty():
		lift_direction *= -1
		for f in target_floor_queue:
			if lift_direction == 1 and f > current_floor:
				possible_floors.append(f)
			elif lift_direction == -1 and f < current_floor:
				possible_floors.append(f)

	# If still none, we're done
	if possible_floors.is_empty():
		next_floor = current_floor
		return

	# Pick nearest in current direction
	var best: int = possible_floors[0]
	var best_d: int = abs(best - current_floor)
	for f in possible_floors:
		var d = abs(f - current_floor)
		if d < best_d:
			best = f
			best_d = d
	next_floor = best

# ---------------- DOOR TIMER ----------------
func _on_door_action_timer_timeout() -> void:
	if door_area.has_overlapping_bodies():
		door_action_timer.start()  # retry if someone still in doorway
	else:
		door_status = DOOR_STATE.CLOSING

# ---------------- DOOR AREA SIGNALS ----------------
func _on_door_area_body_entered(_body: Node2D) -> void:
	if door_status == DOOR_STATE.CLOSING:
		door_status = DOOR_STATE.OPENING
	elif door_status == DOOR_STATE.CLOSED:
		print("Warning: Object entered when door closed!")

func _on_door_area_body_exited(_body: Node2D) -> void:
	if door_status == DOOR_STATE.OPEN and door_area.get_overlapping_bodies().is_empty() and door_action_timer.is_stopped():
		door_action_timer.start()

# ---------------- FLOOR REQUEST ----------------
func add_floor_to_queue(floor_id: int) -> void:
	if floor_id < 0 or floor_id >= total_floors:
		push_error("Invalid floor ID: %s" % floor_id)
		return

	if not target_floor_queue.has(floor_id):
		target_floor_queue.append(floor_id)

	# NEW: If lift is moving, reprioritize if new floor is along current direction
	if lift_status == LIFT_STATE.MOVING and lift_direction != 0:
		if (lift_direction == 1 and floor_id > current_floor and floor_id < next_floor) \
		or (lift_direction == -1 and floor_id < current_floor and floor_id > next_floor):
			next_floor = floor_id

	# If idle, plan next move
	if next_floor == -1 and lift_status == LIFT_STATE.IDLE:
		update_next_floor()
		if door_status == DOOR_STATE.OPEN and door_area.get_overlapping_bodies().is_empty() and door_action_timer.is_stopped():
			door_action_timer.start()

# ---------------- BUTTON SIGNALS ----------------
func _on_ground_pressed() -> void:
	add_floor_to_queue(0)

func _on_first_floor_pressed() -> void:
	add_floor_to_queue(1)

func _on_second_floor_pressed() -> void:
	add_floor_to_queue(2)

func _on_third_floor_pressed() -> void:
	add_floor_to_queue(3)

func _on_open_pressed() -> void:
	if next_floor == -1 and (door_status == DOOR_STATE.CLOSED or door_status == DOOR_STATE.CLOSING):
		door_status = DOOR_STATE.OPENING
