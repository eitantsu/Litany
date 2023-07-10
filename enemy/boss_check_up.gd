tool
extends Leaf

# leaf that checks if up position is close

func execute():
	if agent.global_position.distance_to(agent.up)<=10:
		return statuses.SUCCESS
	else:
		return statuses.FAIL
