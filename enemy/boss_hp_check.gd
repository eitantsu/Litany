tool
extends Leaf

# leaf that checks boss's hp, if above 50% success

func execute():
	if agent.hp>=400:
		return statuses.SUCCESS
	else:
		return statuses.FAIL
