extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	

func _on_start_button_pressed() -> void:
	# We will implement the logic of level load on User current status
	Globals.change_to_scene("res://scene/Level2.tscn")


func _on_exit_button_pressed() -> void:
	pass # Replace with function body.
