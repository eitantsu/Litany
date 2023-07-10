extends State

# state to handle ranged attack

func state_input(event):
	.state_input(event)
	if player.hp<=0:
		return
	if anim_sm.get_current_play_position()/anim_sm.get_current_length()>=0.9:
		if event.is_action_pressed("jump"):
			emit_signal("new_state","Air", {jump = true})
		elif event.is_action_pressed("melee_attack"):
			emit_signal("new_state","Melee_Attack")
		elif event.is_action_pressed("ranged_attack"):
			emit_signal("new_state","Ranged_Attack")

func state_physics_process(delta):
	.state_physics_process(delta)
	if player.hp<=0:
		emit_signal("new_state","Dead")
		return
	if anim_sm.get_current_play_position()/anim_sm.get_current_length()>=0.9: # if animation almost finished change state
		if not is_equal_approx(player.get_direction(),0):
			if(not is_equal_approx(player.get_direction(), player.get_wall_collided())):
				emit_signal("new_state", "Run")
				return
			else:
				if(not is_equal_approx(player.get_direction(),player.get_facing())):
					player.flip() 
					
					
		else:
			emit_signal("new_state","Idle")

func enter_state(values = {}):
	.enter_state(values)
	player.play_sound("ranged")
	player.player_runtime_data.properties["state"] = GlobalVariables.States.RANGED_ATTACK
	anim_tree["parameters/conditions/attack_ranged_stand"] = true
	
	
func exit_state():
	.exit_state()
	anim_tree["parameters/conditions/attack_ranged_stand"] = false
