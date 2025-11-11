class_name pickables
extends Area2D
@onready var label: Label = $Label
@onready var root: Node2D = $".."
@export var mytype:Globals.Pickables = Globals.Pickables.HazardScanner

var player_ref: CharacterBody2D = null
var message:String = 'Press E to Pick '
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if label.visible:
		label.visible = false
	match mytype:
		Globals.Pickables.HazardScanner:
			message += 'Hazard Scanner'
		Globals.Pickables.ElectricalToolBox:
			message += 'Electrical Tool Box'
		Globals.Pickables.ElectricBulb:
			message += 'Electrical Bulb'
		Globals.Pickables.FireExtinguisher:
			message += 'Fire Extinguisher'
		Globals.Pickables.MopTool:
			message += 'Mopping Tool'
	label.text = message

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("action") and player_ref !=null:
		if root.has_method('call_from_pickables'):
			root.call_from_pickables(mytype)
		else:
			push_error('No functino found for call_from_pickables')
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body != null:
		label.visible = true
		player_ref = body

func _on_body_exited(_body: Node2D) -> void:
	label.visible = false
	player_ref = null
