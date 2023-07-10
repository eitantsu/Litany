tool
extends Leaf

# leaf that executes a boss melee
func execute():
	if agent.anim_p.is_playing():
		return statuses.RUNNING
	else:
		return statuses.SUCCESS
	
func start():
	agent.anim_p.play("melee")
