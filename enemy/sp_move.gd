tool
extends Leaf

# leaf that moves enemy
func execute():
	var velocity = Vector2.ZERO
	velocity.x = agent.speed * agent.facing
	velocity.y = agent.gravity
	agent.move_and_slide(velocity,Vector2.UP)
	return statuses.SUCCESS
