tool
extends Leaf

# leaf that flips enemy if reached target point
func execute():
	if agent.left.distance_to(agent.global_position) <= 10:
		agent.facing = 1
		agent.flip()
	if agent.right.distance_to(agent.global_position) <= 10:
		agent.facing = -1
		agent.flip()
	return statuses.SUCCESS

func start():
	if not agent.anim_p.current_animation=="default":
		agent.anim_p.play("default")
