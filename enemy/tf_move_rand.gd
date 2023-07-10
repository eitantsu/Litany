tool
extends Leaf

# leaf that moves enemy towards random chosen direction for a short while
func execute():
	if agent.player_detected:
		return statuses.FAIL
	else:
		var t = blackboard.get("delta") + blackboard.get("time")
		blackboard.set("time",t)
		if t>=1:
			return statuses.SUCCESS
		else:
			var velocity = blackboard.get("rand_pos").normalized()
			velocity *= agent.speed
			agent.move_and_slide(velocity)
			return statuses.RUNNING

func start():
	blackboard.set("time",0.0)
	if blackboard.get("rand_pos").x+agent.position.x > agent.position.x and agent.get_node("Position2D").scale.x==1:
		agent.flip()
		agent.facing = 1
	if blackboard.get("rand_pos").x+agent.position.x < agent.position.x and agent.get_node("Position2D").scale.x==-1:
		agent.flip()
		agent.facing = -1
