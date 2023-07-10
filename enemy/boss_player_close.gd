tool
extends Leaf

# leaf that checks if player close

func execute():
	if agent.raycast(agent.position,agent.position +Vector2(80,0)*agent.facing,pow(2,0)):
			return statuses.SUCCESS
	else:
		return statuses.FAIL
