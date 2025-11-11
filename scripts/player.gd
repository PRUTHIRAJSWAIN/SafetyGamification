extends CharacterBody2D

signal health_changed(new_health)
signal item_equipped(items)

const SPEED = 520.0
const JUMP_VELOCITY = -300.0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var player_health = 74
var player_max_health = 100

var items = {
	Globals.ShieldType.Gloves:false,
	Globals.ShieldType.Helmet:false,
	Globals.ShieldType.Goggles:false,
	Globals.ShieldType.Shoes:false,
	Globals.ShieldType.Headphone:false
}

func _ready() -> void:
	emit_signal("health_changed", player_health)
	emit_signal("item_equipped",items)


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction > 0:
		animated_sprite.flip_h = true
		animated_sprite.play('run')
	elif direction < 0 :
		animated_sprite.flip_h = false
		animated_sprite.play('run')
	else:
		animated_sprite.play('idle')
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
func take_damage(amount:float = 0, giver:Globals.DamageProviderType = Globals.DamageProviderType.None):
	match giver:
		Globals.DamageProviderType.Sound:
			if not items[Globals.ShieldType.Headphone]:
				apply_damage(amount)
		Globals.DamageProviderType.MaterialSpill:
			if not items[Globals.ShieldType.Shoes]:
				apply_damage(amount)
		Globals.DamageProviderType.FallingObject:
			if not items[Globals.ShieldType.Helmet]:
				apply_damage((amount))

func apply_damage(amount:float = 0):
	player_health = max(player_health-amount,0)
	emit_signal("health_changed", player_health)
	if player_health <= 0:
		get_tree().reload_current_scene()

func equip_item(item:Globals.ShieldType):
	items[item] = true
	emit_signal("item_equipped",items)
	
func enable_collision_and_movement(active:bool) ->void :
	# Block/unblock input and collisions together
	set_process_input(active)
	set_physics_process(active)
	set_collision_layer_value(5, active)
	set_collision_mask_value(5, active)
