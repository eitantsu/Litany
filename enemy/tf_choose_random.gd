tool
extends Leaf

# leaf that chooses random direction to move to next
func execute():
	var i = randi()%8
	var pos = Vector2.ZERO
	match i:
		0:
			pos = Vector2(-1,0)
		1:
			pos = Vector2(-1,1)
		2:
			pos = Vector2(0,1)
		3:
			pos = Vector2(1,1)
		4:
			pos = Vector2(1,0)
		5:
			pos = Vector2(1,-1)
		6:
			pos = Vector2(0,-1)
		7:
			pos = Vector2(-1,-1)
	blackboard.set("rand_pos",pos)
	return statuses.SUCCESS
