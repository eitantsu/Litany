extends State

# state when player is "free", can start dialogue, isnt dead, can interact...
class_name Free

func state_input(event :InputEvent):
	.state_input(event)
	if player.hp<=0:
		return
	if(event.is_action_pressed("interact")):
		GameEvents.emit_signal("pressed_interact")
	

func state_physics_process(delta):
	.state_physics_process(delta)

func enter_state(values = {}):
	.enter_state(values)
	player.player_runtime_data.properties["state"] = GlobalVariables.States.FREE

func exit_state():
	.exit_state()

func _ready() -> void:
	GameEvents.connect("start_dialogue", self, "start_dialogue")
	
func start_dialogue(dialogue):
	emit_signal("new_state", "Dialogue")
