extends Control

# load screen logic

export(NodePath) onready var load_pop = get_node(load_pop) as ConfirmationDialog
export(NodePath) onready var back = get_node(back) as Button
export(NodePath) onready var slots = get_node(slots) as ItemList

var slot_to_load
var slot1="user://slot1.tres" # path of the 3 slots
var slot2="user://slot2.tres"
var slot3="user://slot3.tres"

var last_menu

func _ready():
	set_process(false)
	GameEvents.connect("show_load",self,"show_self")
	slots.set_item_tooltip_enabled(0, false)
	slots.set_item_tooltip_enabled(1, false)
	slots.set_item_tooltip_enabled(2, false)

# go back to menu that we came from
func _on_Back_pressed():
	$AudioStreamPlayer.play()
	hide()
	if last_menu=="pause":
		GameEvents.emit_signal("show_pause")
	elif last_menu=="main":
		GameEvents.emit_signal("show_main")
	else:
		GameEvents.emit_signal("show_death")

# show load popup
func _on_Slot_activated(index: int) -> void:
	if not slots.is_item_disabled(index):
		load_pop.popup_centered()
		slot_to_load=index

# call scene manager load func
func _on_load_confirmed() -> void:
	#$AudioStreamPlayer.play()
	match slot_to_load:
		0:
			SceneManager.load_slot(slot1)
		1:
			SceneManager.load_slot(slot2)
		2:
			SceneManager.load_slot(slot3)

# disable slots that have no save files
func _on_LoadScreen_visibility_changed() -> void:
	if visible:
		if not ResourceLoader.exists(slot1):
			slots.set_item_disabled(0,true)
		else:
			slots.set_item_disabled(0,false)
			slots.select(0)
			
		if not ResourceLoader.exists(slot2):
			slots.set_item_disabled(1,true)
		else:
			slots.set_item_disabled(1,false)
			
		if not ResourceLoader.exists(slot3):
			slots.set_item_disabled(2,true)
		else:
			slots.set_item_disabled(2,false)
		
		slots.grab_focus()
		set_process(true)
	else:
		set_process(false)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"): # if in popoup hide it, else exit menu
		if load_pop.visible:
			#$AudioStreamPlayer.play()
			load_pop.hide()
			back.grab_focus()
		else:
			back.emit_signal("pressed")

func show_self(last_m):
	last_menu = last_m
	show()
		

var last_item = null

# double press for touch controls
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
		
	# manually handle button focus because disabled buttons cant be focused
	elif event.is_action_pressed("ui_down"):
		if slots.is_selected(0):
			if not slots.is_item_disabled(1):
				slots.select(1)
			elif not slots.is_item_disabled(2):
				slots.select(2)
			else: back.grab_focus()
		if slots.is_selected(1):
			if not slots.is_item_disabled(2):
				slots.select(2)
			else: back.grab_focus()
			
		if slots.is_item_disabled(0) and slots.is_item_disabled(1) and slots.is_item_disabled(2):
			back.grab_focus()
			
	elif event.is_action_pressed("ui_up"):
		if slots.is_selected(2):
			if not slots.is_item_disabled(1):
				slots.select(1)
			elif not slots.is_item_disabled(0):
				slots.select(0)
		if slots.is_selected(1):
			if not slots.is_item_disabled(0):
				slots.select(0)


func _on_LoadPopup_popup_hide() -> void:
	$AudioStreamPlayer.play()


func _on_LoadPopup_about_to_show() -> void:
	$AudioStreamPlayer.play()
