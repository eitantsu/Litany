extends TouchScreenButton
 
# mobile touch button

func _ready() -> void:
	if OS.get_name()!="Android":
		hide()
	else:
		GameEvents.connect("hide_blur",self,"show")
	GameEvents.connect("player_dead",self,"hide")
	GameEvents.connect("show_death",self,"hide")
	GameEvents.connect("show_inventory",self,"hide")
	GameEvents.connect("show_pause",self,"hide")
	GameEvents.connect("start_dialogue",self,"hide_self")

# hide when in menu
func hide_self(x=0):
	hide()
