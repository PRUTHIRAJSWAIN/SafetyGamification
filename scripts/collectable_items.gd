extends Area2D

@export var itemType:Globals.ShieldType = Globals.ShieldType.None
@onready var label: Label = $PanelContainer/Label
@onready var panel_container: PanelContainer = $PanelContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = "Press E to pick " + Globals.ShieldType.keys()[Globals.ShieldType.values().find(itemType)]
	panel_container.visible = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body != null and is_instance_valid(body):
		if body.is_in_group('Player'):
			panel_container.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body != null and is_instance_valid(body):
		if body.is_in_group('Player'):
			panel_container.visible = false
