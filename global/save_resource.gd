extends Resource

# save resource as a save slot, holds all objects data, and player's data

class_name SaveResource

export(String, FILE, "*.tscn,*.scn") var current_scene
export(Dictionary) var objects
export(Resource) var player_data
export(Resource) var player_inventory
