extends Area2D

@export var DamageGiverType:Globals.DamageProviderType = Globals.DamageProviderType.None
@onready var timer: Timer = $Timer

var damageAmount:float = 0

var targets_in_area:Array = []

func _ready() -> void:
	match  DamageGiverType:
		Globals.DamageProviderType.Sound:
			damageAmount = 2
		Globals.DamageProviderType.MaterialSpill:
			damageAmount = 3
		Globals.DamageProviderType.FallingObject:
			damageAmount = 4
		_:
			pass

func _on_body_entered(body: Node2D) -> void:
	if body != null and is_instance_valid(body):
		if body.is_in_group('Player'):
			targets_in_area.append(body)
			

func _on_body_exited(body: Node2D) -> void:
	targets_in_area.erase(body)
	
func _on_timer_timeout() -> void:
	for target in targets_in_area:
		if target != null and is_instance_valid(target):
			target.take_damage(damageAmount,DamageGiverType)
		
