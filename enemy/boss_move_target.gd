tool
extends Leaf

# leaf that moves boss to target

func execute():
	if agent.facing==1 and blackboard.get("target").x<agent.position.x:
		agent.flip()
		agent.facing=-1
	if agent.facing==-1 and blackboard.get("target").x>agent.position.x:
		agent.flip()
		agent.facing=1
	var velocity = Vector2.ZERO
	velocity = (blackboard.get("target") - agent.position).normalized() * agent.speed
	agent.move_and_slide(velocity)
	return statuses.SUCCESS

func start():
	if not agent.anim_p.current_animation=="fly":
		if agent.anim_p.current_animation_position/agent.anim_p.current_animation_length>=0.9:
			blackboard.set("shoot",false)
			agent.anim_p.play("fly")
