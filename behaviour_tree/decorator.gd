tool
extends Task

# special node that modifies return result
class_name Decorator

func tick():
	if(guard!="null" and (not blackboard.exists(guard) or not blackboard.get(guard))):
		fail()
	else:
		if get_child(0).status != statuses.RUNNING:
			if not (get_child(0).guard!="null" and (not blackboard.exists(get_child(0).guard) or not blackboard.get(get_child(0).guard))):
				get_child(0).start()
		get_child(0).tick()
		
