extends Control

# main menu logic

export(PackedScene) var first_level
export(NodePath) onready var new_game = get_node(new_game) as Button
export(NodePath) onready var quit = get_node(quit) as Button
export(NodePath) onready var loadb = get_node(loadb) as Button
export(NodePath) onready var settings = get_node(settings) as Button

func _ready() -> void:
	OS.center_window()
	new_game.grab_focus()
	GameEvents.connect("show_main",self,"menu_visibility")

#quit game
func _on_Quit_pressed() -> void:
	$AudioStreamPlayer.play()
	yield(get_tree().create_timer(0.1),"timeout")
	get_tree().quit()

# start a new game (first level)
func _on_NewGame_pressed() -> void:
	$AudioStreamPlayer.play()
	SceneManager.reset()
	yield(get_tree().create_timer(0.1),"timeout")
	get_tree().change_scene_to(first_level)

# show load screen
func _on_Load_pressed() -> void:
	$AudioStreamPlayer.play()
	menu_visibility()
	GameEvents.emit_signal("show_load","main")

# show settings screen
func _on_Settings_pressed() -> void:
	$AudioStreamPlayer.play()
	menu_visibility()
	GameEvents.emit_signal("show_settings")

# handle visibility when switching screens
func menu_visibility():
	new_game.visible = !new_game.visible
	if new_game.visible:
		new_game.grab_focus()
	quit.visible = !quit.visible
	loadb.visible = !loadb.visible
	settings.visible = !settings.visible
