tool
extends Composite

# a node that runs children in random order, until fail or end of list

class_name RandomSequence
	
func child_success():
	if(current_child_idx+1 >= children.size()):
		.child_success()
	else:
		running()
		
func child_fail():
	#children.shuffle()
	.child_fail()
	
func init():
	#children.shuffle()
	.init()

func start():
	#children.shuffle()
	.start()

func reset():
	#children.shuffle()
	.reset()
