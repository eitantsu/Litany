tool
extends Leaf

# leaf that makes boss attack with spell

func execute():
	if agent.anim_p.is_playing():
		return statuses.RUNNING
	else:
		return statuses.SUCCESS

func start():
	agent.anim_p.play("spell")
