extends Control

# save screen logic

export(NodePath) onready var slots = get_node(slots) as ItemList
export(NodePath) onready var back = get_node(back) as Button
export(NodePath) onready var save_pop = get_node(save_pop) as ConfirmationDialog

var slot_to_save
var slot1="user://slot1.tres" # slots paths
var slot2="user://slot2.tres"
var slot3="user://slot3.tres"

func _ready() -> void:
	set_process(false)
	GameEvents.connect("show_save",self,"show")
	slots.set_item_tooltip_enabled(0, false)
	slots.set_item_tooltip_enabled(1, false)
	slots.set_item_tooltip_enabled(2, false)

# call scene manager save
func _on_Save_confirmed() -> void:
	match slot_to_save:
		0:
			SceneManager.save_slot(slot1)
		1:
			SceneManager.save_slot(slot2)
		2:
			SceneManager.save_slot(slot3)
	
func _on_Back_pressed() -> void:
	$AudioStreamPlayer.play()
	hide()
	GameEvents.emit_signal("show_pause")

# show save popup
func _on_Slot_activated(index: int) -> void:
	save_pop.popup_centered()
	slot_to_save=index

func _on_SaveScreen_visibility_changed() -> void:
	if visible:
		slots.grab_focus()
		set_process(true)
	else:
		set_process(false)
		
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if save_pop.visible: # if poup visible hide it, else exit
			save_pop.hide()
			back.grab_focus()
		else:
			back.emit_signal("pressed")

var last_item = null

# double press functionality for touchscreen
func _on_SlotList_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.is_pressed():
		var it = slots.get_item_at_position(event.position,true)
		if it!=-1:
			if last_item==it:
				var a = InputEventAction.new()
				a.action = "ui_accept"
				a.pressed = true
				Input.parse_input_event(a)
				yield(get_tree().create_timer(0.05),"timeout")
				a = InputEventAction.new()
				a.action = "ui_accept"
				a.pressed = false
				Input.parse_input_event(a)
				last_item = null
			else:
				last_item = it
		yield(get_tree().create_timer(0.5),"timeout")
		last_item = null


func _on_ConfirmationDialog_popup_hide() -> void:
	$AudioStreamPlayer.play()


func _on_ConfirmationDialog_about_to_show() -> void:
	$AudioStreamPlayer.play()
