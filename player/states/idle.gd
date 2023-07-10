extends Free

# state to handle when not doing anything

func state_input(event):
	.state_input(event)
	if player.hp<=0:
		return
	if event.is_action_pressed("jump"):
		player.play_sound("jump")
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
	
	player.velocity.x=0
	player.velocity.y=player.gravity
	player.velocity.y = player.move_and_slide_with_snap(player.velocity,Vector2.ZERO,Vector2.UP,true,4,deg2rad(player.max_angle)).y
	if not player.on_floor():
		emit_signal("new_state","Air",{jump = false})
		return		
		
	if not is_equal_approx(player.get_direction(),0):
		if(not is_equal_approx(player.get_direction(), player.get_wall_collided())):
			emit_signal("new_state", "Run")
		else:
			if(not is_equal_approx(player.get_direction(),player.get_facing())):
				player.flip()

func enter_state(values = {}):
	.enter_state(values)
	player.player_runtime_data.properties["state"] = GlobalVariables.States.IDLE
	anim_tree["parameters/conditions/idle"] = true
	
func exit_state():
	.exit_state()
	anim_tree["parameters/conditions/idle"] = false
