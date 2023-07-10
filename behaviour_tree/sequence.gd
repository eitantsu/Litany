tool
extends Composite

# a node that runs children until fail or end of list

class_name Sequence
	
func child_success():
	active_child = null
	if(current_child_idx+1 >= children.size()): # if last node success
		.child_success()
	else:
		running()
