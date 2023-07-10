tool
extends Task

# a special node that runs children in some order


class_name Composite

var active_child = null
var children = get_children()
var current_child_idx = -1 

func init():
	active_child = null
	current_child_idx = -1 
	children = get_children()
	parent = get_parent() as Task
	btree = parent.btree
	blackboard = parent.blackboard
	agent = parent.agent
	status = statuses.SUCCESS
	for child in get_children():
		child.init()

func tick():
	if(guard!="null" and (not blackboard.exists(guard) or not blackboard.get(guard))):
		fail()
	else:
		if active_child != null: #if active child not null run it
			active_child.tick()
		else:
			var child = next_child() # otherwise run next child
			if child.status != statuses.RUNNING:
				if not (child.guard!="null" and (not blackboard.exists(child.guard) or not blackboard.get(child.guard))):
					child.start()
			child.tick()
		
func child_running():
	active_child = children[current_child_idx]
	running()
	
func child_success():
	current_child_idx = -1 
	active_child = null
	success()

func child_fail():
	current_child_idx = -1 
	active_child = null
	fail()
	
func start():
	current_child_idx = -1 
	active_child = null

func reset():
	current_child_idx = -1
	active_child = null
	
func next_child(): # get next child in list
	current_child_idx+=1
	return children[current_child_idx]
