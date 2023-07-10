tool
extends Leaf

# leaf that checks boss's current target

func execute():
	if agent.global_position.distance_to(agent.left)<=10:
		blackboard.set("target",agent.up)
		blackboard.set("prev","left")
		blackboard.set("shoot",true)
	elif agent.global_position.distance_to(agent.up)<=10:
		if blackboard.get("prev")=="left":
			blackboard.set("target",agent.right)
		else:
			blackboard.set("target",agent.left)
		blackboard.set("shoot",true)
	elif agent.global_position.distance_to(agent.right)<=10:
		blackboard.set("target",agent.up)
		blackboard.set("shoot",true)
		blackboard.set("prev","right")
	return statuses.SUCCESS

func start():
	if not blackboard.exists("target"):
		blackboard.set("target",agent.left)
	if not blackboard.exists("shoot"):
		blackboard.set("shoot",false)
