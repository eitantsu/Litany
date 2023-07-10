tool
extends Task

# a special node type, acts as the root node.

class_name BehaviourTree

func _ready() -> void:
	if not Engine.editor_hint:
		agent = get_parent()
		blackboard = Blackboard.new()
		btree = self 
		for child in get_children():
			child.init()
		set_physics_process(false)
		yield(GameEvents,"player_ready") # wait until player is ready to begin the tree
		set_physics_process(true)

func tick():
	var root :Task = get_child(0) # get the child and run it
	if root.status != statuses.RUNNING:
		root.start()
	root.tick()
	
func _physics_process(delta: float) -> void:
	if not Engine.editor_hint:
		blackboard.set("delta",delta) # set delta time, other nodes might need it
		tick()
