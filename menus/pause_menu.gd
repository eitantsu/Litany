extends Control

# pause menu logic

export(String, FILE, "*.tscn,*.scn") var main_menu_scene_path
export(NodePath) onready var popup = get_node(popup) as ConfirmationDialog
export(NodePath) onready var resume = get_node(resume) as Button
export(NodePath) onready var save = get_node(save) as Button

var quit_type
var detections_count := 0 # counter for how many enemies detect player currently

func _ready() -> void:
	GameEvents.connect("show_pause",self,"show")
	GameEvents.connect("is_player_detected",self,"update_counts")
	set_process(false)

# show quit popup
func _on_QuitGame_pressed() -> void:
	quit_type="game"
	popup.popup_centered()


func _on_PausePopup_confirmed() -> void:
	if quit_type=="game":
		get_tree().quit() # quit game
	else:
		get_tree().paused=false
		get_tree().change_scene(main_menu_scene_path) # quit to main menu


func _on_QuitToMainMenu_pressed() -> void:
	quit_type="menu"
	popup.popup_centered()

# resume play
func _on_Resume_pressed() -> void:
	$AudioStreamPlayer.play()
	hide()
	GameEvents.emit_signal("hide_blur")
	get_tree().paused=false

# show settings
func _on_Settings_pressed() -> void:
	$AudioStreamPlayer.play()
	hide()
	GameEvents.emit_signal("show_settings")

# show save screen
func _on_Save_pressed() -> void:
	$AudioStreamPlayer.play()
	hide()
	GameEvents.emit_signal("show_save")

# show load screen
func _on_Load_pressed() -> void:
	$AudioStreamPlayer.play()
	hide()
	GameEvents.emit_signal("show_load","pause")

func _on_PauseMenu_visibility_changed() -> void:
	if visible:
		yield(get_tree().create_timer(0.1), "timeout")
		resume.grab_focus()
		set_process(true)
	else:
		set_process(false)

# popup text change depending on context
func _on_PausePopup_about_to_show() -> void:
	$AudioStreamPlayer.play()
	if quit_type=="game":
		popup.dialog_text="Make sure to save the game before quitting.\nAre you sure you want to quit the game?"
		popup.window_title="Quit game"
	else:
		popup.dialog_text="Make sure to save the game before quitting.\nAre you sure you want to quit to the main menu?"
		popup.window_title="Quit to main menu"

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if popup.visible: # if popup visible hide, else exit menu
			popup.hide()
			resume.grab_focus()
		else:
			resume.emit_signal("pressed")

# add to detection counter, or subtract from it
func update_counts(detected):
	if detected:
		detections_count+=1
		save.disabled = true
	else:
		detections_count-=1
		if detections_count==0:
			save.disabled = false


func _on_PausePopup_popup_hide() -> void:
	$AudioStreamPlayer.play()
