class_name lift
extends Node2D

@export var my_floor_id: int = 0
@onready var lift_button_proximity: Area2D = $LiftButtonProximity
@onready var left_door: Sprite2D = $LeftDoor
@onready var right_door: Sprite2D = $RightDoor
@onready var liftWall: StaticBody2D = $StaticBody2D
@onready var label: Label = $PanelContainer/Label
@onready var message_hide_timer: Timer = $MessageHideTimer
@onready var MessageContainer: PanelContainer = $PanelContainer
@onready var player_spawn_point: Marker2D = $PlayerSpawnPoint
@onready var floor_display: Label = $FloorDisplay

var player_ref:CharacterBody2D = null
var isPlayerAlreadyInside:bool = false
var TargetFloor:int = -1
const lift_speed = 100


func _ready() -> void:
	MessageContainer.visible = false
	liftWall.visible = false
	floor_display.text = "G" if my_floor_id == 0 else str(my_floor_id)
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("action") and player_ref != null and not isPlayerAlreadyInside:
		if TargetFloor == -1:
			label.text = tr("Select a floor to use lift")
			show_message()
		else:
			isPlayerAlreadyInside = true
			# Move player to center of lift 
			player_ref.global_position = player_spawn_point.global_position
			# Adjust z-index order (doors in front, player behind)
			left_door.z_index = 6
			right_door.z_index = 6
			# Enable the collision of lift wall
			DisableLiftWallCollision(false)
			await close_doors_fully()
			# When door fully closed reduce the players z-index as he is going to travel thought different floor
			if player_ref == null:
				push_error("No player detected")
				return
			var sprite = player_ref.get_node("AnimatedSprite2D")
			if sprite == null:
				push_error("Sprite for player animation not found in lift")
			sprite.z_index = 0
			left_door.z_index = 0
			right_door.z_index = 0
			# Once door closed, call level scene function to move player to target lift (pass lift id)
			var targetLift:lift = null
			for cur_lift in get_parent().get_children():
				if cur_lift is lift and cur_lift.my_floor_id == TargetFloor:
					targetLift = cur_lift
					break
			move_player_to_target_lift(targetLift)
		
func _on_ground_pressed() -> void:
	button_pressed(0)

func _on_first_floor_pressed() -> void:
	button_pressed(1)

func _on_second_floor_pressed() -> void:
	button_pressed(2)

func _on_third_floor_pressed() -> void:
	button_pressed(3)
	
func button_pressed(floor_id:int):
	if lift_button_proximity.get_overlapping_bodies().is_empty():
		label.text = tr("Move closer to the lift to press the button")
		show_message()
	elif floor_id == my_floor_id:
		pass
	else:
		TargetFloor = floor_id
		# Do not reopen door if player is already inside
		if not isPlayerAlreadyInside:
			open_door_fully()


func open_door_fully() -> void:
	if not right_door.region_enabled:
		right_door.region_enabled = true
	if not left_door.region_enabled:
		left_door.region_enabled = true
	var start_left_rect = left_door.region_rect
	var end_left_rect = Rect2(310.0, start_left_rect.position.y, start_left_rect.size.x, start_left_rect.size.y)

	var left_tween = create_tween()
	left_tween.tween_property(left_door, "region_rect", end_left_rect, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var start_right_rect = right_door.region_rect
	var end_right_rect = Rect2(392.3, start_right_rect.position.y, start_right_rect.size.x, start_right_rect.size.y)

	var right_tween = create_tween()
	right_tween.tween_property(right_door, "region_rect", end_right_rect, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	await left_tween.finished
	await right_tween.finished
	
func close_doors_fully() -> void:
	if not right_door.region_enabled:
		right_door.region_enabled = true
	if not left_door.region_enabled:
		left_door.region_enabled = true
	var left_tween = create_tween()
	left_tween.tween_property(left_door, "region_rect", Rect2(256.0, left_door.region_rect.position.y, left_door.region_rect.size.x, left_door.region_rect.size.y), 1.2)

	var right_tween = create_tween()
	right_tween.tween_property(right_door, "region_rect", Rect2(449.0, right_door.region_rect.position.y, right_door.region_rect.size.x, right_door.region_rect.size.y), 1.2)

	await left_tween.finished
	await right_tween.finished

func DisableLiftWallCollision(newValue:bool):
	for shape in liftWall.get_children():
		if shape is CollisionShape2D:
			shape.disabled = newValue
		
func _on_inside_lift_detection_body_entered(body: Node2D) -> void:
	if not isPlayerAlreadyInside and body != null:
		player_ref = body
		if TargetFloor != -1:
			label.text = tr("Press E to enter into lift")
		else:
			label.text = tr("Select a floor to use lift")
		show_message()
		
func show_message():
	MessageContainer.visible = true
	if not message_hide_timer.is_stopped():
		message_hide_timer.stop()
	message_hide_timer.start()

func _on_message_hide_timer_timeout() -> void:
	MessageContainer.visible = false
	
# This will get call once the player reached target floor to reset its variables
func ResetLiftStatus():
	player_ref = null
	isPlayerAlreadyInside = false
	TargetFloor = -1
	DisableLiftWallCollision(true)
	
func move_player_to_target_lift(target_lift:lift) -> void:
	if player_ref == null or target_lift == null:
		push_error("Player or Target lift is not set.")
		return
		
	var start_pos = player_ref.global_position
	var end_pos = target_lift.player_spawn_point.global_position
	var transition_time = start_pos.distance_to(end_pos) / lift_speed
	
	# Reset lift status as next processing are going to happen in target lift
	var moving_player = player_ref
	ResetLiftStatus()
	
	# Before animation stop player's movement and collison for smooth transition
	moving_player.enable_collision_and_movement(false)
	
	var travel_tween = create_tween()
	travel_tween.tween_property(moving_player,"global_position",end_pos,transition_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	# when tween finished start the event at target lift
	travel_tween.finished.connect(Callable(target_lift, "on_player_arrived_from_other_lift").bind(moving_player))
	
func on_player_arrived_from_other_lift(arrived_player:CharacterBody2D) -> void: 
	if arrived_player == null:
		push_error("Invalid Player value sent")
	# First increase door index then reset player index to bring him back to normal then after opening reset door index
	left_door.z_index = 6
	right_door.z_index = 6
	var sprite = arrived_player.get_node("AnimatedSprite2D")
	if sprite == null:
			push_error("Sprite for player animation not found in lift")
	sprite.z_index = 5
	# Re-enable players collison and movement
	arrived_player.enable_collision_and_movement(true)
	await open_door_fully()
	left_door.z_index = 0
	right_door.z_index = 0
	await  close_doors_fully()
	
	
