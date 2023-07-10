tool
extends Leaf

# leaf that gets next position in path to move to
func execute():
	var pos = agent.player_data.properties["position"]
	var path = agent.navigation.get_simple_path(agent.position,pos)
	if not pos in path:
		return statuses.FAIL
	else:
		blackboard.set("next_pos",path[1])
		return statuses.SUCCESS
