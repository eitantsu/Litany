extends Control

# death screen logic

export(NodePath) onready var load_button = get_node(load_button) as Button
export(NodePath) onready var popup = get_node(popup) as ConfirmationDialog
export(String, FILE, "*.tscn,*.scn") var main_menu_scene_path

func _on_DeathMenu_visibility_changed() -> void:
	if visible:
		load_button.grab_focus()

# show load screen
func _on_Load_pressed() -> void:
	$AudioStreamPlayer.play()
	hide()
	GameEvents.emit_signal("show_load","death")

# show quit game poup
func _on_QuitGame_pressed() -> void:
	popup.popup_centered()
	hide()

# quit to main menu
func _on_QuitMenu_pressed() -> void:
	$AudioStreamPlayer.play()
	hide()
	yield(get_tree().create_timer(0.1),"timeout")
	get_tree().paused = false
	get_tree().change_scene(main_menu_scene_path) 

func _ready() -> void:
	GameEvents.connect("player_dead",self,"show")
	GameEvents.connect("show_death",self,"show")

# quit the game
func _on_ConfirmationDialog_confirmed() -> void: 
	get_tree().quit()

func _on_ConfirmationDialog_popup_hide() -> void:
	$AudioStreamPlayer.play()
	show()


func _on_ConfirmationDialog_about_to_show() -> void:
	$AudioStreamPlayer.play()
