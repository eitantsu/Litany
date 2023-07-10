tool
extends Leaf

# leaf that checks if enemy is close to player
func execute():
	if agent.raycast(agent.position,agent.position +Vector2(30,0)*agent.facing,pow(2,0)):
			return statuses.SUCCESS
	else:
		return statuses.FAIL
