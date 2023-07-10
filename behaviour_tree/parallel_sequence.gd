tool
extends Composite

# a node that runs all children in a single frame, until fail or end of list

class_name Parallel_Sequence
	
func child_success():
	active_child = null
	if(current_child_idx+1 >= children.size()):
		current_child_idx = -1 
		.child_success()

func tick():
	if(guard!="null" and (not blackboard.exists(guard) or not blackboard.get(guard))):
		fail()
	else:
		for i in children.size():
			var child = next_child()
			if child.status != statuses.FAIL:
				if not (child.guard!="null" and (not blackboard.exists(child.guard) or not blackboard.get(child.guard))):
					child.start()
			child.tick()

func child_fail():
	current_child_idx = -1 
	active_child = null
	fail()
