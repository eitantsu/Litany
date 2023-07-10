tool
extends Leaf

# leaf that checks if player is in range for a ranged attack
func execute():
	if agent.raycast(agent.position,agent.position +Vector2(70,0)*agent.facing,pow(2,0)):
		return statuses.SUCCESS
	else:
		return statuses.FAIL
