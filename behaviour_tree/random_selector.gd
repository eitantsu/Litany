tool
extends Composite
 
# a node that runs children in random order, until success or end of list

class_name RandomSelector

func child_success():
	children.shuffle()
	.child_success()
		
func child_fail():
	if(current_child_idx+1 >= children.size()):
		children.shuffle()
		.child_fail()
	else:
		running()
	
func init():
	var c = get_children()
	c.shuffle()
	children = c
	.init()

func start():
	children.shuffle()
	.start()

func reset():
	children.shuffle()
	.reset()
