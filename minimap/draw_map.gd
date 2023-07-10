extends Node2D

# logic for drawing minimap on screen

export(Resource) var player_runtime_data

export(Texture) var player_t
export(Texture) var intr
export(Texture) var room_t
export(Texture) var door
export(Texture) var npc
export(Texture) var enemy

# continously update own player position
func _process(delta: float) -> void:
	$PlayerPosition.position = player_runtime_data.properties["position"]
	update()


func _draw() -> void:
	var paths = get_tree().get_nodes_in_group("Rooms") # draw rooms' bounding region
	for p in paths:
		var points = p.curve.get_baked_points()
		for pp in points:
			draw_texture(room_t,pp)
			
	draw_texture(player_t,$PlayerPosition.position) # draw player marker

	var poi = get_tree().get_nodes_in_group("points_of_interest") # draw other objects markers
	for p in poi:
		draw_texture(intr,p.position-Vector2(0,20))

	var doors = get_tree().get_nodes_in_group("SceneZones") # draw scene change zones markers
	for p in doors:
		draw_texture(door,p.position-Vector2(0,20))

	var npcs = get_tree().get_nodes_in_group("npcs") # draw npcs markers
	for p in npcs:
		draw_texture(npc,p.position-Vector2(0,20))
	
	var enemies = get_tree().get_nodes_in_group("enemies") # draw enemies markers
	for p in enemies:
		draw_texture(enemy,p.position-Vector2(0,20))
		
	var doors2 = get_tree().get_nodes_in_group("end") # draw end door
	for p in doors2:
		draw_texture(door,p.position-Vector2(0,20))
