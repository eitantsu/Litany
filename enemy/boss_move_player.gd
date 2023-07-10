tool
extends Leaf

# leaf that moves boss to target

func execute():
	blackboard.set("target",agent.player_data.properties["position"])
	if agent.facing==1 and blackboard.get("target").x<agent.position.x:
		agent.flip()
		agent.facing=-1
	if agent.facing==-1 and blackboard.get("target").x>agent.position.x:
		agent.flip()
		agent.facing=1
	var velocity = Vector2.ZERO
	velocity = (blackboard.get("target") - agent.position).normalized() * agent.speed/4
	agent.move_and_slide(velocity)
	var t = blackboard.get("time2") + blackboard.get("delta")
	blackboard.set("time2",t)
	if agent.global_position.distance_to(blackboard.get("target"))<=60 or blackboard.get("time2")>=4:
		return statuses.SUCCESS
	else:
		return statuses.RUNNING

func start():
	blackboard.set("time2",0)
	if not agent.anim_p.current_animation=="fly":
		if agent.anim_p.current_animation_position/agent.anim_p.current_animation_length>=0.9:
			blackboard.set("shoot",false)
			agent.anim_p.play("fly")
