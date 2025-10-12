extends Control

@onready var progress_bar:TextureProgressBar = $TextureProgressBar
@onready var googles: TextureRect = $HBoxContainer/pc2/Googles
@onready var gloves: TextureRect = $HBoxContainer/pc3/Gloves
@onready var helmet: TextureRect = $HBoxContainer/pc4/helmet
@onready var shoes: TextureRect = $HBoxContainer/pc5/Shoes
@onready var headphone: TextureRect = $HBoxContainer/pc1/Headphone


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func update_health(value):
	progress_bar.value = clamp(value,0,100)

func update_items(items):
	var icons = {
		Globals.ShieldType.Gloves: gloves,
		Globals.ShieldType.Goggles: googles,
		Globals.ShieldType.Helmet: helmet,
		Globals.ShieldType.Shoes: shoes,
		Globals.ShieldType.Headphone: headphone
	}
	for shield_type in icons:
		if items[shield_type]:
			icons[shield_type].self_modulate = Color(1.0, 1.0, 1.0, 1.0)
		else:
			icons[shield_type].self_modulate = Color(0.0, 0.0, 0.0, 0.635)
