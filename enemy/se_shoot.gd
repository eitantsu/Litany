tool
extends Leaf

# leaf that causes enemy to make a ranged attack
func execute():
	agent.anim_p.play("ranged_attack")
	return statuses.SUCCESS
