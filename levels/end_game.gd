extends Area2D

export(String, FILE, "*.tscn,*.scn") var main_menu_scene_path

# last zone, finished game, go back to main menu
func _on_Area2D_body_entered(body: Node) -> void:
	if body.get_collision_layer_bit(0):
		get_tree().change_scene(main_menu_scene_path)
