extends Node2D

enum DOOR_STATE {OPEN,OPENING,CLOSING,CLOSED}

@onready var door_body: StaticBody2D = $DoorBody
@onready var door_area: Area2D = $DoorArea
@onready var door_action_timer: Timer = $DoorActionTimer

var door_scale_max:float = 0.235
var door_scale_min:float = 1.00
var door_closing_speed = 2 # pixel per frame
var door_status:DOOR_STATE=DOOR_STATE.OPEN

func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if door_status == DOOR_STATE.OPENING:
		door_body.scale.y = lerp(door_body.scale.y,door_scale_min,delta * door_closing_speed)
	elif door_status == DOOR_STATE.CLOSING:
		door_body.scale.y = lerp(door_body.scale.y,door_scale_max,delta * door_closing_speed)

func _on_door_area_area_entered(area: Area2D) -> void:
	if door_status == DOOR_STATE.CLOSING:
		door_status = DOOR_STATE.OPENING
	if door_status == DOOR_STATE.CLOSED:
		push_error('Object Entered into Area2d When door is closed')


func _on_door_area_area_exited(area: Area2D) -> void:
	if door_status == DOOR_STATE.OPEN:
		door_action_timer.start()
	

func _on_door_action_timer_timeout() -> void:
	door_status =DOOR_STATE.CLOSING
