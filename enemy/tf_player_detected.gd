tool
extends Leaf

# leaf that checks if player is detected
func execute():
	if agent.player_detected:
		return statuses.SUCCESS
	else:
		return statuses.FAIL
