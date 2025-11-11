extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player = $CharacterBody2D
	var ui = $CanvasLayer/UI
	player.connect('health_changed',Callable(ui,'update_health'))
	player.connect('item_equipped',Callable(ui,'update_items'))
	
	# first call to sync ui with player after all scenes gets loaded
	ui.update_health(player.player_health)
	ui.update_items(player.items)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_accept_dialog_confirmed() -> void:
	get_tree().paused = false
