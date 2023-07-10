tool
extends Leaf

# leaf that targets up position

func execute():
	blackboard.set("target",agent.up)
	return statuses.SUCCESS
