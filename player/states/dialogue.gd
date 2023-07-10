extends State

# state to handle dialogue

func state_input(event :InputEvent):
	.state_input(event)
	if player.hp<=0:
		return
	if event.is_action_released("jump"):
		GameEvents.emit_signal("advance_dialogue")
	if event.is_action_released("ui_cancel"):
		GameEvents.emit_signal("end_dialogue")

func state_physics_process(delta):
	.state_physics_process(delta)

func enter_state(values = {}):
	.enter_state(values)
	anim_sm.stop()
	player.play_sound("menus")
	player.player_runtime_data.properties["state"] = GlobalVariables.States.DIALOGUE

func exit_state():
	.exit_state()

func _ready() -> void:
	GameEvents.connect("end_dialogue",self,"end_dialogue")

# hide blur when finished dialogue
func end_dialogue():
	yield(get_tree(),"idle_frame")
	GameEvents.emit_signal("hide_blur")
	emit_signal("new_state","Idle")
