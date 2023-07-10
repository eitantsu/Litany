tool
extends Leaf

func execute():
	return statuses.SUCCESS

func start():
	agent.anim_p.play("shoot")
