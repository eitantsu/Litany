extends State

# state to handle movement in air

var can_coyote := false

func state_input(event):
	.state_input(event)
	if player.hp<=0:
		return
	if (event.is_action_released("jump")): # if jump key released, immediately put high gravity
		player.gravity = 80
	if (event.is_action_pressed("jump")):
		if can_coyote and (state_machine.stack.front()=="Idle" or state_machine.stack.front()=="Run"):
			player.play_sound("jump")
			anim_tree["parameters/conditions/jump"] = true
			anim_tree["parameters/conditions/fall"] = false
			player.velocity.y = -player.jump
		else:
			hang_time()

# logic when in air, allow to move a bit when in air, handle falling
func state_physics_process(delta): 
	.state_physics_process(delta)
#	if player.hp<=0:
#		emit_signal("new_state","Dead")
#		return
	var direction = player.get_direction()
	if(not is_equal_approx(direction,player.get_wall_collided())):
		player.velocity.x = direction * player.speed
	else: 
		player.velocity.x=0 
	
	if not is_equal_approx(player.get_facing(),direction) and not is_equal_approx(direction,0): player.flip()
	player.velocity.y += player.gravity
	player.velocity = player.move_and_slide(player.velocity,Vector2.UP,true)
	
	if player.is_on_ceiling(): # if hit a ceiling immediately put high gravity
		player.velocity.y=player.gravity
		
	if player.velocity.y>=0:
		anim_tree["parameters/conditions/jump"] = false
		anim_tree["parameters/conditions/fall"] = true
	if player.on_floor():
		player.gravity = 55
		if not is_equal_approx(player.get_direction(),0):
			emit_signal("new_state","Run")
			return
		else:
			emit_signal("new_state","Idle")
			return

# check if we entered air state because of jumping, or simply falling of edge
func enter_state(values = {}):
	.enter_state(values)
	player.player_runtime_data.properties["state"] = GlobalVariables.States.AIR
	if values["jump"] == true:
		player.play_sound("jump")
		anim_tree["parameters/conditions/jump"] = true
		anim_tree["parameters/conditions/fall"] = false
		player.velocity.y -= player.jump
	else:
		coyote_time()
		#anim_tree["parameters/conditions/fall"] = true

# coyote time allows player to jump for a brief moment after walking of an edge even if player isnt on the floor
func coyote_time():
	can_coyote = true
	yield(get_tree().create_timer(0.1),"timeout")
	can_coyote = false

# hang time allows player to jump again before actually falling down to floor for smoother experience
func hang_time():
	yield(get_tree().create_timer(0.08),"timeout")
	if(player.on_floor()):
		emit_signal("new_state","Air", {jump = true})
	
func exit_state():
	.exit_state()
	anim_tree["parameters/conditions/jump"] = false
	anim_tree["parameters/conditions/fall"] = false
