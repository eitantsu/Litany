tool
extends Composite

# a node that runs children until success or end of list

class_name Selector

func child_fail():
	active_child = null
	if(current_child_idx+1 >= children.size()): # if this is the last node, fail
		.child_fail()
	else:
		running()
