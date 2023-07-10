tool
extends Label

# base node

class_name Task

enum statuses {RUNNING,SUCCESS,FAIL} # types of node statuses

var parent :Task = null
var btree = null
var agent:Enemy = null
var blackboard :Blackboard = null
var status = statuses.SUCCESS
export(String) var guard = "null"

# initializing vars before run
func init():
	parent = get_parent() as Task
	btree = parent.btree
	blackboard = parent.blackboard
	agent = parent.agent
	status = statuses.SUCCESS
	for child in get_children():
		child.init()

# call parent running
func running():
	status=statuses.RUNNING
	if parent!=null:
		parent.child_running()

# call parent fail
func fail():
	status=statuses.FAIL
	end()
	if parent!=null:
		parent.child_fail()

#call parent success
func success():
	status=statuses.SUCCESS
	end()
	if parent!=null:
		parent.child_success()

#every frame logic
func tick():
	pass

# logic when child succeeds
func child_success():
	success()

# logic when child fails
func child_fail():
	fail()

# logic when child still running
func child_running():
	running()

# logic on the first time called
func start():
	pass

# logic when exiting
func end():
	pass

# func to reset vars
func reset():
	pass

func _process(delta: float) -> void:
	update()

# when inside editor draw lines to visualize tree in a nice way
func _draw() -> void:
	if Engine.editor_hint:
		text=name
		show()
		if get_parent() != null and get_parent() as Task:
			var to=get_global_transform().affine_inverse().xform(get_parent().rect_global_position+Vector2(get_parent().rect_size.x/2,get_parent().rect_size.y))
			var from=get_global_transform().affine_inverse().xform(rect_global_position+Vector2(rect_size.x/2,0))
			draw_rect(Rect2(get_global_transform().affine_inverse().xform(rect_global_position),rect_size),Color.brown,false,2)
			draw_line(from,to,Color.aqua,3)
			
	else:
		hide()
	
