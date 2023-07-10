tool
extends Leaf

# leaf that checks if enemy is facing player
func execute():
	var pos = agent.player_data.properties["position"]
	var relative_pos
	if pos.x > agent.position.x:
		relative_pos = 1
	else:
		relative_pos = -1
	if (agent.facing * relative_pos == 1) or (agent.facing * relative_pos == -1):
			return statuses.SUCCESS
	else:
		return statuses.FAIL
