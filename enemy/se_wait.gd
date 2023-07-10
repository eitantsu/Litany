tool
extends Leaf

# leaf that waits for a set time
func execute():
	var t = blackboard.get("time") + blackboard.get("delta")
	blackboard.set("time",t)
	if t>=1.5:
		return statuses.SUCCESS
	else:
		return statuses.RUNNING


func start():
	blackboard.set("time",0)
