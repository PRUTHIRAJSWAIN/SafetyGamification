class_name hazard
extends Area2D
@export var who_can_fix_me:Globals.Pickables = Globals.Pickables.HazardScanner
@onready var root: Node2D = $".."
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var label: Label = $Label
var player_ref:CharacterBody2D = null

var is_holding_e: bool = false
var speed: float = 40.0  # how fast the bar decreases per second	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	progress_bar.visible = false
	
func _process(delta: float) -> void:
	# Check if player is holding E
	is_holding_e = Input.is_action_pressed("action")  # Make sure 'interact' is mapped to E in Input Map

	if player_ref != null and is_holding_e and root.has_method('player_has_guard') and root.player_has_guard(who_can_fix_me):
		progress_bar.value -= speed * delta
		if progress_bar.value <= 0:
			progress_bar.value = 0
			if root.has_method('hazard_cleared'):
				root.hazard_cleared(who_can_fix_me)
			queue_free()
	else:
		# Reset bar when not holding
		progress_bar.value = 100

func _on_body_entered(body: Node2D) -> void:
	if body != null:
		player_ref = body
		if root.has_method('can_hazard_lit'):
			if root.can_hazard_lit():
				progress_bar.visible = true
				if root.has_method('player_has_guard'):
					if root.player_has_guard(who_can_fix_me):
						label.text = tr('Hold E to fix this')
					else:
						label.text = tr('Hazard detected! You need {tool} to fix this').format({'tool':str(Globals.Pickables.keys()[who_can_fix_me])})
					label.visible = true


func _on_body_exited(_body: Node2D) -> void:
	player_ref = null
	label.visible = false
	progress_bar.visible = false

func reveal_hazard():
	if not progress_bar.visible:
		progress_bar.value = 100
		progress_bar.visible = true
	
