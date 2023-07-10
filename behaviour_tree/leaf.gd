tool
extends Task

# a node at the end of a branch, doesnt have children

class_name Leaf

func execute(): # the logic of a certain leaf, returns result
	pass

func tick():
	if(guard!="null" and (not blackboard.exists(guard) or not blackboard.get(guard))):
		fail()
	else:
		var res = execute()
		match res:
			statuses.SUCCESS:
				success()
			statuses.FAIL:
				fail()
			statuses.RUNNING:
				running()
