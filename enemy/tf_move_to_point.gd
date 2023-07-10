tool
extends Leaf

# leaf that moves enemy
func execute():
	if agent.facing==1 and agent.player_data.properties["position"].x<agent.position.x:
		agent.flip()
		agent.facing=-1
	if agent.facing==-1 and agent.player_data.properties["position"].x>agent.position.x:
		agent.flip()
		agent.facing=1
	var velocity = Vector2.ZERO
	velocity = (blackboard.get("next_pos") - agent.position).normalized() * agent.speed *4
	agent.move_and_slide(velocity)
	return statuses.SUCCESS
