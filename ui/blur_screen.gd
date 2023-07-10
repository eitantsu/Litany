extends TextureRect

# a blur screen that shows up when in menus, to hide background

func _ready() -> void:
	GameEvents.connect("start_dialogue",self,"show_self")
	GameEvents.connect("show_pause",self,"show")
	GameEvents.connect("show_inventory",self,"show")
	GameEvents.connect("player_dead",self,"show")
	GameEvents.connect("hide_blur",self,"hide")

func show_self(arg):
	show()
