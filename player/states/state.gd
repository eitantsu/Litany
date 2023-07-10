extends Node

signal new_state(state_name, values)

# state from the "state pattern"
# special states inherit this and expand on the code

class_name State

onready var player :Player = owner
onready var anim_sm :AnimationNodeStateMachinePlayback = player.get_node("AnimationTree").get("parameters/playback")
onready var anim_tree :AnimationTree = player.get_node("AnimationTree")
var state_machine
export(bool) var include_in_stack := true # if this state should be kept in the stack history

# handling state input
func state_input(event :InputEvent):
	pass

# handling logic of every frame
func state_physics_process(delta):
	if player.position.y>=1000 and player.player_runtime_data.properties["state"]!=GlobalVariables.States.DEAD:
		emit_signal("new_state","Dead")

# logic to do when we change into this state
func enter_state(values = {}):
	pass

# logic to do when we change from this state to another
func exit_state():
	pass
