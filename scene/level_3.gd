extends Node2D
@onready var cb_smoke: CheckBox = $CanvasLayer/VBoxContainer/PanelContainer9/cb_smoke
var people_total = 5
var people_cur = 0
var smoke_total = 2
var smoke_cur = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func update_avl_hazard_cnt():
	cb_smoke.text = tr("{remain}/{total} Smoke Removed").format({"remain": smoke_cur,"total": smoke_total})
	if smoke_cur == smoke_total:
		cb_smoke.button_pressed = true
	
func call_from_pickables(sender_type:Globals.Pickables) -> void:
	match sender_type:
		Globals.Pickables.FireExtinguisher:
			$CanvasLayer/VBoxContainer/PanelContainer2/cb_FireEx.button_pressed = true
		Globals.Pickables.FireAlarm:
			$CanvasLayer/VBoxContainer/PanelContainer3/cb_FireAlarm.button_pressed = true
	update_avl_hazard_cnt()

func player_has_guard(item:Globals.Pickables):
	match item:
		Globals.Pickables.FireExtinguisher:
			if $CanvasLayer/VBoxContainer/PanelContainer2/cb_FireEx.button_pressed:
				return true
	return false

func hazard_cleared(item:Globals.Pickables):
	match item:
		Globals.Pickables.FireExtinguisher:
			smoke_cur += 1
	update_avl_hazard_cnt()

func can_hazard_lit():
	return true
