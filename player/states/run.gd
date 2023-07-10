extends Free

# state when player is running

func state_input(event):
	.state_input(event)
	if player.hp<=0:
		return
	if event.is_action_pressed("jump"):
		emit_signal("new_state","Air", {jump=true})
	elif event.is_action_pressed("melee_attack"):
		emit_signal("new_state","Melee_Attack")
	elif event.is_action_pressed("ranged_attack"):
		emit_signal("new_state","Ranged_Attack")

func state_physics_process(delta):
	.state_physics_process(delta)
	if player.hp<=0:
		emit_signal("new_state","Dead")
		return
	if not player.on_floor():
		emit_signal("new_state","Air",{jump=false})
		return
		
	player.velocity.x = 0
	var facing = player.get_facing()
	var direction = player.get_direction()

	# if not moving, change to idle
	if is_equal_approx(direction,0) or is_equal_approx(direction,player.get_wall_collided()):
		emit_signal("new_state","Idle")
		return
		
	if not is_equal_approx(facing,direction): player.flip()
	
	player.velocity.x = player.speed * direction
	player.velocity.y = player.gravity
	var snap=Vector2.DOWN*32
	player.velocity.y = player.move_and_slide_with_snap(player.velocity,snap,Vector2.UP,true,4,deg2rad(player.max_angle)).y

func enter_state(values = {}):
	.enter_state(values)
	player.player_runtime_data.properties["state"] = GlobalVariables.States.RUN
	anim_tree["parameters/conditions/run"] = true
	
func exit_state():
	.exit_state()
	anim_tree["parameters/conditions/run"] = false
