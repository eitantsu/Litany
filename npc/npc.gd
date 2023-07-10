extends Area2D

# logic for npc interaction

export(Resource) var player_runtime_data = player_runtime_data as PlayerRuntimeData
export(Resource) var dialogue = dialogue as DialogueResource
var player_inside := false

# if player inside interact zone, can now interact
func _on_Area2D_body_entered(body: Node) -> void:
	if body.get_collision_layer_bit(0):
		GameEvents.connect("pressed_interact",self,"attempt_dialogue_start")
		player_inside=true
	
# player left, no longer interact
func _on_Area2D_body_exited(body: Node) -> void:
	if body.get_collision_layer_bit(0):
		GameEvents.disconnect("pressed_interact",self,"attempt_dialogue_start")
		player_inside=false

# attempt dialogue
func attempt_dialogue_start():
	if dialogue and player_runtime_data:
		# if player nearby and state is able to start dialogue
		if player_inside \
		and (player_runtime_data.properties["state"] == GlobalVariables.States.IDLE \
		or player_runtime_data.properties["state"] == GlobalVariables.States.FREE \
		or player_runtime_data.properties["state"] == GlobalVariables.States.RUN):
			var areas = get_overlapping_areas()
			for area in areas:
				if area.get_collision_layer_bit(2): # if player is closer to npc than anything else, start dialogue, else dont.
					if area.position.distance_to(player_runtime_data.properties["position"]) < position.distance_to(player_runtime_data.properties["position"]):
						return
			GameEvents.emit_signal("start_dialogue", dialogue)
