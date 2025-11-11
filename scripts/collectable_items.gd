extends Area2D

@export var itemType:Globals.ShieldType = Globals.ShieldType.None
@onready var label: Label = $PanelContainer/Label
@onready var panel_container: PanelContainer = $PanelContainer
var player_ref:CharacterBody2D = null
@onready var singleitem: Sprite2D = $singleitem
@onready var carrier: Sprite2D = $Carrier
var item_available = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = "Press E to pick " + Globals.ShieldType.keys()[Globals.ShieldType.values().find(itemType)]
	panel_container.visible = false
	match itemType:
		Globals.ShieldType.Gloves:
			carrier.region_rect = Rect2(49,0.0,58,153)
			singleitem.region_rect = Rect2(15,64,40,39)
		Globals.ShieldType.Helmet:
			carrier.region_rect = Rect2(444,00,68,157)
			singleitem.region_rect = Rect2(399,43,53,85)
		Globals.ShieldType.Goggles:
			carrier.region_rect = Rect2(165,0,27,157)
			singleitem.region_rect = Rect2(128,33,29,106)
		Globals.ShieldType.Shoes:
			carrier.region_rect = Rect2(272,5,97,154)
			singleitem.region_rect = Rect2(232,58,28,58)
		Globals.ShieldType.Headphone:
			carrier.region_rect = Rect2(111,104,63,153)
			singleitem.region_rect = Rect2(43,148,68,108)
			
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func _physics_process(_delta: float) -> void:
	if item_available and Input.is_action_just_pressed("action") and player_ref != null :
		player_ref.equip_item(itemType)
		item_available = false
		singleitem.visible = false

func _on_body_entered(body: Node2D) -> void:
	if item_available and body != null and is_instance_valid(body) and item_available:
		if body.is_in_group('Player'):
			panel_container.visible = true
			player_ref = body


func _on_body_exited(body: Node2D) -> void:
	if body != null and is_instance_valid(body):
		if body.is_in_group('Player'):
			panel_container.visible = false
			player_ref = null
