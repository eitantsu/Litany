extends State

# state when dead, cant do anything

func enter_state(values = {}):
	.enter_state(values)
	player.play_sound("dead")
	player.player_runtime_data.properties["state"] = GlobalVariables.States.DEAD
	if player.on_floor():
		anim_tree["parameters/conditions/dead"] = true
	GameEvents.emit_signal("player_dead")
	
func exit_state():
	.exit_state()
	anim_tree["parameters/conditions/dead"] = false
