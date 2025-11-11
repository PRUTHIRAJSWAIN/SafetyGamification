extends Node2D

@onready var instructions: PanelContainer = $CanvasLayer/Instructions
@onready var cb_scanner: CheckBox = $CanvasLayer/VBoxContainer/PanelContainer/cb_scanner
@onready var cb_fire_ex: CheckBox = $CanvasLayer/VBoxContainer/PanelContainer2/cb_FireEx
@onready var cb_elect_tool: CheckBox = $CanvasLayer/VBoxContainer/PanelContainer3/cb_ElectTool
@onready var cb_moping: CheckBox = $CanvasLayer/VBoxContainer/PanelContainer4/cb_Moping
@onready var cb_bulb: CheckBox = $CanvasLayer/VBoxContainer/PanelContainer5/cb_Bulb
@onready var cb_bulbrepair: CheckBox = $CanvasLayer/VBoxContainer/PanelContainer6/cb_bulbrepair
@onready var cb_firerepair: CheckBox = $CanvasLayer/VBoxContainer/PanelContainer7/cb_firerepair
@onready var cb_spillclear: CheckBox = $CanvasLayer/VBoxContainer/PanelContainer8/cb_spillclear
@onready var cb_wirebroken: CheckBox = $CanvasLayer/VBoxContainer/PanelContainer9/cb_wirebroken

#Hardcoded
var cnt_fire:int = 0
var cnt_light:int = 0
var cnt_wiring:int = 0
var cnt_spill:int = 0

var cnt_fire_total:int = 2
var cnt_light_total:int = 2
var cnt_wiring_total:int = 2
var cnt_spill_total:int = 2

var hazardScannerActive:bool = true
var PlayerHasHazardScanner:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_avl_hazard_cnt()
	get_tree().paused = true
	instructions.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
		

func call_from_pickables(sender_type:Globals.Pickables) -> void:
	match sender_type:
		Globals.Pickables.HazardScanner:
			enableHazardScanner()
		Globals.Pickables.ElectricalToolBox:
			enableElectricalTool()
		Globals.Pickables.ElectricBulb:
			enableElectricBulb()
		Globals.Pickables.FireExtinguisher:
			enableFireExtinguisher()
		Globals.Pickables.MopTool:
			enableMopTool()
			
func update_avl_hazard_cnt():
	cb_bulbrepair.text = tr("{remain}/{total} Bulb Replaced").format({"remain": cnt_light,"total": cnt_light_total})
	if cnt_light == cnt_light_total:
		cb_bulbrepair.button_pressed = true
	cb_wirebroken.text = tr("{remain}/{total} Bad Wiring Fixed").format({"remain": cnt_wiring,"total": cnt_wiring_total})
	if cnt_wiring == cnt_wiring_total:
		cb_wirebroken.button_pressed = true
	cb_firerepair.text = tr("{remain}/{total} Fire Extinguisher Placed").format({"remain": cnt_fire,"total": cnt_fire_total})
	if cnt_fire == cnt_fire_total:
		cb_firerepair.button_pressed = true
	cb_spillclear.text = tr("{remain}/{total} Chemical Spill Cleaned").format({"remain": cnt_spill,"total": cnt_spill_total})
	if cnt_spill == cnt_spill_total:
		cb_spillclear.button_pressed = true
		
func hazard_cleared(item:Globals.Pickables) -> void:
	match item:
		Globals.Pickables.ElectricBulb:
			cnt_light += 1
			#cb_bulbrepair.text = str(cnt_light) + '/2 Bulb Replaced'
		Globals.Pickables.ElectricalToolBox:
			cnt_wiring += 1
			#cb_wirebroken.text = str(cnt_wiring) + '/2 Bad Wiring Fixed'
		Globals.Pickables.FireExtinguisher:
			cnt_fire += 1
			#cb_firerepair.text = str(cnt_fire) + '/2 Fire Extinguishers Placed'
		Globals.Pickables.MopTool:
			cnt_spill += 1
	update_avl_hazard_cnt()
			
func can_hazard_lit():
	if hazardScannerActive and PlayerHasHazardScanner:
		return true
	return false
func player_has_guard(item:Globals.Pickables):
	match item:
		Globals.Pickables.ElectricBulb:
			if cb_bulb.button_pressed:
				return true
		Globals.Pickables.ElectricalToolBox:
			if cb_elect_tool.button_pressed:
				return true
		Globals.Pickables.FireExtinguisher:
			if cb_fire_ex.button_pressed:
				return true
		Globals.Pickables.MopTool:
			if cb_moping.button_pressed:
				return true
	return false
func enableHazardScanner():
	PlayerHasHazardScanner = true
	cb_scanner.button_pressed = true
func enableElectricalTool():
	cb_elect_tool.button_pressed = true
func enableElectricBulb():
	cb_bulb.button_pressed = true
func enableFireExtinguisher():
	cb_fire_ex.button_pressed = true
func enableMopTool():
	cb_moping.button_pressed = true
	


func _on_exit_point_body_entered(_body: Node2D) -> void:
	if cnt_fire == cnt_fire_total and cnt_light == cnt_light_total and cnt_wiring == cnt_wiring_total and cnt_spill == cnt_spill_total:
		pass
	else:
		$ExitPoint/Label.visible = true

func _on_exit_point_body_exited(_body: Node2D) -> void:
	$ExitPoint/Label.visible = false
