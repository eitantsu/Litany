tool
extends Leaf

# leaf that sets player position as target

func execute():
	blackboard.set("target",agent.player_data.properties["position"])
	return statuses.SUCCESS
