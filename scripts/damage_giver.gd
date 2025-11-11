extends Area2D

@export var DamageGiverType:Globals.DamageProviderType = Globals.DamageProviderType.None
@onready var timer: Timer = $Timer
@onready var vfx_container: Node2D = $VfxContainer
@onready var spill: Sprite2D = $VfxContainer/Spill
@onready var welding: AnimatedSprite2D = $VfxContainer/Welding

var damageAmount:float = 0
var targets_in_area:Array = []
var first_time = true
var message_text = ""

func _ready() -> void:
	spill.visible = false
	welding.visible = false
	match DamageGiverType:
		Globals.DamageProviderType.Sound:
			damageAmount = 2
			message_text = "⚠️ Loud noise ahead! Ear protection advised."
			_start_sound_wave_vfx()
		Globals.DamageProviderType.MaterialSpill:
			damageAmount = 3
			spill.visible = true
		Globals.DamageProviderType.FallingObject:
			damageAmount = 4
			message_text = "⚠️ Watch out! Falling objects zone."
			welding.visible = true
		Globals.DamageProviderType.BrightLight:
			damageAmount = 2
			welding.visible = true
		_:
			pass

# ---------------------------
#   DAMAGE LOGIC
# ---------------------------
func _on_body_entered(body: Node2D) -> void:
	if body and is_instance_valid(body):
		if body.is_in_group("Player"):
			targets_in_area.append(body)

func _on_body_exited(body: Node2D) -> void:
	targets_in_area.erase(body)

func _on_timer_timeout() -> void:
	for target in targets_in_area:
		if target and is_instance_valid(target):
			if first_time:
				first_time = false
				get_tree().paused = true
				Globals.show_dialogue(message_text)
			target.take_damage(damageAmount, DamageGiverType)
# ---------------------------
#   VISUAL EFFECTS SECTION
# ---------------------------

# 🔊 SOUND — Expanding Circular Waves
func _start_sound_wave_vfx() -> void:
	var wave_timer := Timer.new()
	wave_timer.wait_time = 0.5
	wave_timer.autostart = true
	wave_timer.one_shot = false
	wave_timer.timeout.connect(_spawn_sound_wave)
	add_child(wave_timer)

func _spawn_sound_wave() -> void:
	var wave = ColorRect.new()
	wave.color = Color(0.2, 0.6, 1.0, 0.25)  # light blue, semi-transparent
	wave.size = Vector2(16, 16)

	# Set pivot to center so scaling happens from center
	wave.pivot_offset = wave.size / 2

	# Position at the center of VFX container
	wave.position = Vector2(-8,-128) #Vector2.ZERO

	vfx_container.add_child(wave)

	# Tween for scale and fade
	var tween = create_tween()
	tween.tween_property(wave, "scale", Vector2(16, 16), 2.0)  # expand
	tween.tween_property(wave, "modulate:a", 0.0, 2.0)        # fade out
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	# Free wave after tween finishes
	tween.connect("finished", Callable(wave, "queue_free"))


func _on_wave_finished(wave: Node) -> void:
	if wave and is_instance_valid(wave):
		wave.queue_free()
