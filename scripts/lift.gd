extends Node2D

enum DOOR_STATE { OPEN, OPENING, CLOSING, CLOSED }

@onready var door_body: Node2D = $DoorBody
@onready var door_area: Area2D = $DoorArea
@onready var door_action_timer: Timer = $DoorActionTimer

var door_scale_max: float = 1
var door_scale_min: float = 0.235
var door_speed: float = 1.0
var door_status: DOOR_STATE = DOOR_STATE.OPEN
var total_floors = 4
var target_floor_queue :Array[bool]= [false] * total_floors
var current_floor:int = 0
var next_floor:int = current_floor
var lift_movement_speed:float = 1.0
var floor_offset:float = 256.0


func _process(delta: float) -> void:
	match door_status:
		DOOR_STATE.OPENING:
			door_body.scale = door_body.scale.move_toward(Vector2(door_body.scale.x, door_scale_min), door_speed * delta)
			if abs(door_body.scale.y - door_scale_min) < 0.001:
				door_body.scale.y = door_scale_min
				door_status = DOOR_STATE.OPEN

		DOOR_STATE.CLOSING:
			door_body.scale = door_body.scale.move_toward(Vector2(door_body.scale.x, door_scale_max), door_speed * delta)
			if abs(door_body.scale.y - door_scale_max) < 0.001:
				door_body.scale.y = door_scale_max
				door_status = DOOR_STATE.CLOSED
				
		DOOR_STATE.CLOSED:
			if next_floor != current_floor:
				var target_floor_location = Vector2(position.x, next_floor * floor_offset)
				position = position.move_toward(target_floor_location,delta * lift_movement_speed)
				# when lift reached
				if position.distance_to(target_floor_location)<1.0:
					update_next_floor()
					door_status = DOOR_STATE.OPENING
				
	
func update_next_floor():
	var possible_next = -1
	if current_floor < next_floor:
		for i in range(current_floor+1,len(target_floor_queue)):
			if target_floor_queue[i]:
				pass
	elif current_floor > next_floor:
		pass

func _on_door_action_timer_timeout() -> void:
	if door_area.has_overlapping_bodies():
		print("Person still inside, delaying close")
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

func add_floor_to_queue(floor_id:int): # we will recive the floor index starting from zero
	if total_floors >= (floor_id + 1):
		target_floor_queue[floor_id] = true

func _on_ground_pressed() -> void:
	add_floor_to_queue(0) 


func _on_ground_2_pressed() -> void:
	add_floor_to_queue(1) 
