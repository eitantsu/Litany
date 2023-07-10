extends Node

# implementation of hierarchial stack based finite state machine
# in charge of handling changing states logic

class_name StateMachine

export(NodePath) onready var initial_state = get_node(initial_state) as State # state to start with
var states:={}
var stack:=[] # history stack
onready var current_state :State=initial_state 

func _ready() -> void:
	for state in get_children():
		if state.get_child_count()==0:
			states[state.name]=state
			state.state_machine = self
			state.connect("new_state",self,"change_state")
	stack.push_front(current_state.name)
	current_state.enter_state()

# every frame do process of current state
func _physics_process(delta: float) -> void:
	current_state.state_physics_process(delta)

# if got input, let state handle it
func _unhandled_input(event: InputEvent) -> void:
	current_state.state_input(event)

# when we get signal to change, change to new state, and push state to stack
func change_state(new_state, values :Dictionary = {}):
	current_state.exit_state()
	if current_state.include_in_stack:
		stack.push_front(current_state.name)
	if stack.size()>100:
		stack.pop_back()
	current_state=states[new_state]
	current_state.enter_state(values)
