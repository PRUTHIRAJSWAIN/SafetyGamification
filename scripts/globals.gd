extends Node

enum DamageProviderType {
	None,
	Sound,
	MaterialSpill,
	FallingObject,
	BrightLight,
}
enum ShieldType{
	None, Gloves, Helmet, Goggles, Shoes,Headphone
}

enum Pickables{
	HazardScanner,ElectricalToolBox,ElectricBulb,FireExtinguisher,MopTool,FireAlarm
}

func change_to_scene(scene_path: String) -> void:
	var packed_scene = load(scene_path)
	if packed_scene:
		get_tree().change_scene_to_packed(packed_scene)
		# Adjust mouse depending on scene
		#if scene_path.ends_with("Level1.tscn"):
		if true:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		push_error("Scene path invalid: %s" % scene_path)

func show_dialogue(message):
	var popup:AcceptDialog = get_tree().current_scene.get_node_or_null("CanvasLayer/AcceptDialog")
	if popup:
		popup.dialog_text = message
		popup.visible = true
	else:
		push_error("Popup not found in  this scene")
	
