extends Control 

# settings screen logic

export(NodePath) onready var window = get_node(window) as OptionButton
export(NodePath) onready var back = get_node(back) as Button
export(NodePath) onready var resolutions = get_node(resolutions) as OptionButton
export(NodePath) onready var popup_key = get_node(popup_key) as ConfirmationDialog
export(NodePath) onready var popup_def = get_node(popup_def) as ConfirmationDialog
export(NodePath) onready var keyboard1 = get_node(keyboard1) as ItemList
export(NodePath) onready var keyboard2 = get_node(keyboard2) as ItemList
export(Array, String) var actions # action names list
var keyboard1_codes # codes for keyboard controls
var keyboard2_codes
var changekey :=false # if currently changing a key
var idx_keychange # index of new key
var new_key
var current_change_control_node # if changing keyboard or joystick

var default_settings_path="user://default_settings.cfg"

var settings_path="user://settings.cfg"
var resolutions_list=[]

export(NodePath) onready var controller = get_node(controller) as ItemList
var controller_codes

export(NodePath) onready var volume = get_node(volume) as HSlider
export(NodePath) onready var actions_names = get_node(actions_names) as ItemList
export(bool) var in_main := false

var window_opened:=false
var res_opened:=false

func _ready() -> void:
	set_process(false)
	set_process_input(false)
	GameEvents.connect("show_settings",self,"show")
	
	window.get_popup().connect("hide",self,"hide_options")
	resolutions.get_popup().connect("hide",self,"hide_options")
	
	var num = actions_names.get_item_count()
	for i in range(num):
		actions_names.set_item_tooltip_enabled(i,false)
	
	if OS.get_name()=="Android": # if on android hide settings not relevant for mobile
		window.hide()
		resolutions.hide()
		keyboard1.hide()
		keyboard2.hide()
		controller.hide()
		actions_names.hide()

	
	keyboard1_codes=[]
	keyboard2_codes=[]
	controller_codes=[]
	
	# populate resolutions list
	var num_items=resolutions.get_item_count()
	for i in range(num_items):
		var res=resolutions.get_item_text(i)
		var width=int(res.substr(0,res.find("x")))
		var height=int(res.substr(res.find("x")+1))
		resolutions_list.push_back(Vector2(width,height))
		
		
	# make default settings file if doesnt exist
	var default_settings = ConfigFile.new()
	var err = default_settings.load(default_settings_path)
	if err == ERR_FILE_NOT_FOUND:
		for action in actions:
			var keys = InputMap.get_action_list(action)
			var keystemp =[]
			var buttonjoy
			for k in keys:
				if k is InputEventKey:
					keystemp.append(k)
				else:
					if k is InputEventJoypadButton:
						buttonjoy = k
			keys=keystemp
			# set controls default settings
			if keys.size()==2:
				default_settings.set_value("keyboard_controls", action,[keys[0].scancode,keys[1].scancode])
			else:
				default_settings.set_value("keyboard_controls", action,[keys[0].scancode,-1])
				
			default_settings.set_value("controller_controls",action,buttonjoy.button_index)
		
		# set resolution default settings
		default_settings.set_value("display", "window", "fullscreen")
		if not OS.get_name()=="Android":
			default_settings.set_value("display", "resolution_height", 1080)
			default_settings.set_value("display", "resolution_width", 1920)
		else:
			default_settings.set_value("display", "resolution_height", 1280)
			default_settings.set_value("display", "resolution_width", 720)
		# audio default settings
		default_settings.set_value("sound","volume", 0)
		default_settings.save(default_settings_path)
		
	
	# if no settings file create from default, else load current
	var game_settings = ConfigFile.new()
	err = game_settings.load(settings_path)
	if(err == ERR_FILE_NOT_FOUND):
		load_settings(true)
	else:
		load_settings(false)

# update screen settings
func _on_Window_item_selected(index: int) -> void:
	$AudioStreamPlayer.play()
	var game_settings = ConfigFile.new()
	var err = game_settings.load(settings_path)
	if err == OK:
		if(index==0):
			OS.window_fullscreen=false
			var w = resolutions_list[resolutions.selected][0]
			var h = resolutions_list[resolutions.selected][1]
			OS.window_size=Vector2(w,h)
			OS.center_window()
			game_settings.set_value("display", "window","windowed")
		if(index==1):
			OS.window_fullscreen=true
			game_settings.set_value("display", "window","fullscreen")
		game_settings.save(settings_path)

# update resolution settings
func _on_Resolutions_item_selected(index: int) -> void:
	$AudioStreamPlayer.play()
	OS.window_size=resolutions_list[index]
	OS.center_window()
	var game_settings = ConfigFile.new()
	var err = game_settings.load(settings_path)
	if err == OK:
		game_settings.set_value("display", "resolution_height",resolutions_list[index][1])
		game_settings.set_value("display", "resolution_width", resolutions_list[index][0])
		game_settings.save(settings_path)

# go back to previous menu
func _on_Back_pressed() -> void:
	$AudioStreamPlayer.play()
	hide()
	if in_main:
		GameEvents.emit_signal("show_main")
	else:
		GameEvents.emit_signal("show_pause")

# change old key to new key
func _on_ChangeKey_confirmed() -> void:
	var event
	if current_change_control_node!="controller":
		event = InputEventKey.new()
		event.scancode=new_key
	else:
		event = InputEventJoypadButton.new()
		event.button_index = new_key
		
	InputMap.action_add_event(actions[idx_keychange],event) # add new key to action
	if current_change_control_node=="keyboard1":
		keyboard1.set_item_text(idx_keychange, event.as_text()) # set itemlist text to button text
	elif current_change_control_node=="keyboard2":
		keyboard2.set_item_text(idx_keychange, event.as_text())
	elif current_change_control_node=="controller":
		controller.set_item_text(idx_keychange,Input.get_joy_button_string(event.button_index))
	
	# update settings file
	var game_settings = ConfigFile.new()
	var err = game_settings.load(settings_path)
	if err == OK:
		if current_change_control_node=="keyboard1":
			game_settings.set_value("keyboard_controls",actions[idx_keychange],[new_key,keyboard2_codes[idx_keychange]])
			var old_event = InputEventKey.new()
			old_event.scancode=keyboard1_codes[idx_keychange]
			InputMap.action_erase_event(actions[idx_keychange],old_event)
			keyboard1_codes[idx_keychange] = new_key
		elif current_change_control_node=="keyboard2":
			game_settings.set_value("keyboard_controls",actions[idx_keychange],[keyboard2_codes[idx_keychange],new_key])
			var old_event = InputEventKey.new()
			old_event.scancode=keyboard2_codes[idx_keychange]
			InputMap.action_erase_event(actions[idx_keychange],old_event)
			keyboard2_codes[idx_keychange] = new_key
		elif current_change_control_node=="controller":
			game_settings.set_value("controller_controls",actions[idx_keychange],new_key)
			var old_event = InputEventJoypadButton.new()
			old_event.button_index=controller_codes[idx_keychange]
			InputMap.action_erase_event(actions[idx_keychange],old_event)
			controller_codes[idx_keychange] = new_key
		game_settings.save(settings_path)
	
func _on_Settings_visibility_changed() -> void:
	if visible:
		window.grab_focus()
		set_process(true)
		set_process_input(true)
	else:
		set_process(false)
		set_process_input(false)


func _on_KeyboardControls1_focus_exited() -> void:
	keyboard1.unselect_all()
	
func _on_KeyboardControls2_focus_exited() -> void:
	keyboard2.unselect_all()


# keyboard primary button change key
func _on_KeyboardControls1_item_activated(index: int) -> void:
	popup_key.get_cancel().disabled=true
	popup_key.get_cancel().focus_mode=Control.FOCUS_NONE
	popup_key.get_ok().disabled=true
	popup_key.get_ok().focus_mode=Control.FOCUS_NONE
	
	if keyboard1.is_item_disabled(index):
		return
	popup_key.dialog_text="Tap key..."
	changekey=true
	idx_keychange=index
	current_change_control_node="keyboard1"
	popup_key.popup_centered()

# get new key func
func replace_key():
	$AudioStreamPlayer.play()
	if current_change_control_node!="controller":
		var old_event = InputEventKey.new()
		if current_change_control_node=="keyboard1":
			old_event.scancode=keyboard1_codes[idx_keychange]
		else:
			old_event.scancode=keyboard2_codes[idx_keychange]
		var new_event = InputEventKey.new()
		new_event.scancode=new_key
		# show in popup text, what are we changing into what new key
		popup_key.dialog_text="Change mapping of "+actions[idx_keychange]+":\n"+old_event.as_text()+" -> "+new_event.as_text()
	else:
		var old_event =InputEventJoypadButton.new()
		old_event.button_index=controller_codes[idx_keychange]
		var new_event = InputEventJoypadButton.new()
		new_event.button_index=new_key
		popup_key.dialog_text="Change mapping of "+actions[idx_keychange]+":\n"+Input.get_joy_button_string(old_event.button_index)+" -> "+Input.get_joy_button_string(new_event.button_index)
	
	popup_key.get_cancel().disabled=false
	popup_key.get_cancel().focus_mode=Control.FOCUS_ALL
	popup_key.get_ok().disabled=false
	popup_key.get_ok().focus_mode=Control.FOCUS_ALL
	popup_key.get_cancel().grab_focus()

func _on_Default_pressed() -> void:
	$AudioStreamPlayer.play()
	popup_def.popup_centered()

# load settings form settings file
func load_settings(default):
	var game_settings = ConfigFile.new()
	var gerr = game_settings.load(settings_path)

	# if want to default, reset settings file to default settings
	if default:
		var default_settings = ConfigFile.new()
		var derr = default_settings.load(default_settings_path)
		if derr == ERR_FILE_NOT_FOUND or derr == OK: 
			var sections = default_settings.get_sections()
			for section in sections:
				var section_keys = default_settings.get_section_keys(section)
				for section_key in section_keys:
					var val = default_settings.get_value(section,section_key)
					game_settings.set_value(section,section_key,val)
			game_settings.save(settings_path)
		else: return
		

	# load settings from settings file
	if default or gerr==OK:
		# load resolutions
		var height = game_settings.get_value("display","resolution_height")
		var width = game_settings.get_value("display","resolution_width")
		resolutions.select(resolutions_list.find(Vector2(width,height)))
		OS.window_size=Vector2(width,height)
		
		# load volume
		var value = game_settings.get_value("sound","volume")
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Global"), value)
		volume.value = value
		
		# load window mode
		var win = game_settings.get_value("display","window")
		if win == "fullscreen":
			OS.window_fullscreen=true
			window.select(1)
		else:
			OS.window_fullscreen=false
			window.select(0)

		# load actions
		for action in actions:
			InputMap.action_erase_events(action)
			var left = InputEventJoypadMotion.new()
			left.axis = JOY_AXIS_0
			left.axis_value = -1
			InputMap.action_add_event("left",left)
			var right = InputEventJoypadMotion.new()
			right.axis = JOY_AXIS_0
			right.axis_value = 1
			InputMap.action_add_event("right",right)
		
		#load keyboard controls
		var keyboard_controls = game_settings.get_section_keys("keyboard_controls")
		for action in keyboard_controls:
			var controls = game_settings.get_value("keyboard_controls", action)
			var event1 = InputEventKey.new()
			event1.scancode = controls[0]
			InputMap.action_add_event(action,event1)
			if(controls[1]!=-1):
				var event2 = InputEventKey.new()
				event2.scancode = controls[1]
				InputMap.action_add_event(action,event2)
			keyboard1_codes.push_back(controls[0])
			keyboard2_codes.push_back(controls[1])
			
		keyboard1.clear()
		keyboard2.clear()
		for action in actions:
			var controls = game_settings.get_value("keyboard_controls",action)
			var event1 = InputEventKey.new()
			event1.scancode=controls[0]
			keyboard1.add_item(event1.as_text())
			if(controls[1]!=-1):
				var event2 = InputEventKey.new()
				event2.scancode=controls[1]
				keyboard2.add_item(event2.as_text())
			else:
				keyboard2.add_item("-----")
				keyboard2.set_item_disabled(keyboard2.get_item_count()-1,true)
				
				
				
		# load controller controls
		var joy_controls = game_settings.get_section_keys("controller_controls")
		for action in joy_controls:
			var controls = game_settings.get_value("controller_controls", action)
			controller_codes.push_back(controls)
			var event1 = InputEventJoypadButton.new()
			event1.button_index = controls
			InputMap.action_add_event(action,event1)

		controller.clear()
		for action in actions:
			var controls = game_settings.get_value("controller_controls",action)
			var event1 = InputEventJoypadButton.new()
			event1.button_index=controls
			controller.add_item(Input.get_joy_button_string(controls))
			
		var num
		num = keyboard1.get_item_count()
		for i in range(num):
			keyboard1.set_item_tooltip_enabled(i,false)
		num = keyboard2.get_item_count()
		for i in range(num):
			keyboard2.set_item_tooltip_enabled(i,false)
		num = controller.get_item_count()
		for i in range(num):
			controller.set_item_tooltip_enabled(i,false)

# keyboard alternative button change key
func _on_KeyboardControls2_item_activated(index: int) -> void:
	popup_key.get_cancel().disabled=true
	popup_key.get_cancel().focus_mode=Control.FOCUS_NONE
	popup_key.get_ok().disabled=true
	popup_key.get_ok().focus_mode=Control.FOCUS_NONE
	
	if keyboard2.is_item_disabled(index):
		return
	popup_key.dialog_text="Tap key..."
	changekey=true
	idx_keychange=index
	current_change_control_node="keyboard2"
	popup_key.popup_centered()

# load default
func _on_RemapDefault_confirmed() -> void:
	$AudioStreamPlayer.play()
	load_settings(true)

func _process(delta: float) -> void:
	if not changekey:
		if Input.is_action_just_pressed("ui_cancel"):
			if popup_key.visible: #if not changing key, if popup visible hide it, else exit
				popup_key.hide()
				window.grab_focus()
			elif popup_def.visible:
				popup_def.hide()
				window.grab_focus()
			elif window_opened:
				window.get_popup().hide()
			elif res_opened:
				resolutions.get_popup().hide()
			else:
				back.emit_signal("pressed")

# capture the key to change to
func _input(event: InputEvent) -> void:
	if changekey:
		if event.is_action_pressed("ui_cancel"):
			changekey = false
			return
		if event.is_action_pressed("ui_accept"):
			changekey = false
			return
		if event is InputEventKey and event.is_pressed() and current_change_control_node!="controller":
			changekey=false
			new_key = event.scancode
			replace_key()
		elif event is InputEventJoypadButton and event.is_pressed() and current_change_control_node=="controller":
			changekey=false
			new_key = event.button_index
			replace_key()


func _on_ControllerControls_focus_exited() -> void:
	controller.unselect_all()

# change controller controls
func _on_ControllerControls_item_activated(index: int) -> void:
	popup_key.get_cancel().disabled=true
	popup_key.get_cancel().focus_mode=Control.FOCUS_NONE
	popup_key.get_ok().disabled=true
	popup_key.get_ok().focus_mode=Control.FOCUS_NONE
	
	if controller.is_item_disabled(index):
		return
	popup_key.dialog_text="Tap button..."
	changekey=true
	idx_keychange=index
	current_change_control_node="controller"
	popup_key.popup_centered()

# change volume setting
func _on_Volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Global"), value)
	var game_settings = ConfigFile.new()
	var err = game_settings.load(settings_path)
	if err == OK:
		game_settings.set_value("sound","volume",value)
		game_settings.save(settings_path)

var last_item1 = null
var last_item2 = null
var last_item3 = null

# double press functionality for touchscreen
func _on_KeyboardControls1_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.is_pressed():
			var it = keyboard1.get_item_at_position(event.position,true)
			if it!=-1:
				if last_item1==it:
					var a = InputEventAction.new()
					a.action = "ui_accept"
					a.pressed = true
					Input.parse_input_event(a)
					yield(get_tree().create_timer(0.05),"timeout")
					a = InputEventAction.new()
					a.action = "ui_accept"
					a.pressed = false
					Input.parse_input_event(a)
					last_item1 = null
				else:
					last_item1 = it
			yield(get_tree().create_timer(0.5),"timeout")
			last_item1 = null

# double press functionality for touchscreen
func _on_KeyboardControls2_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.is_pressed():
			var it = keyboard2.get_item_at_position(event.position,true)
			if it!=-1:
				if last_item2==it:
					var a = InputEventAction.new()
					a.action = "ui_accept"
					a.pressed = true
					Input.parse_input_event(a)
					yield(get_tree().create_timer(0.05),"timeout")
					a = InputEventAction.new()
					a.action = "ui_accept"
					a.pressed = false
					Input.parse_input_event(a)
					last_item2 = null
				else:
					last_item2 = it
			yield(get_tree().create_timer(0.5),"timeout")
			last_item2 = null

# double press functionality for touchscreen
func _on_ControllerControls_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.is_pressed():
			var it = controller.get_item_at_position(event.position,true)
			if it!=-1:
				if last_item3==it:
					var a = InputEventAction.new()
					a.action = "ui_accept"
					a.pressed = true
					Input.parse_input_event(a)
					yield(get_tree().create_timer(0.05),"timeout")
					a = InputEventAction.new()
					a.action = "ui_accept"
					a.pressed = false
					Input.parse_input_event(a)
					last_item3 = null
				else:
					last_item3 = it
			yield(get_tree().create_timer(0.5),"timeout")
			last_item3 = null


func _on_ChangeKey_popup_hide() -> void:
	$AudioStreamPlayer.play()


func _on_RemapDefault_popup_hide() -> void:
	$AudioStreamPlayer.play()


func _on_Window_pressed() -> void:
	window_opened=true


func _on_Resolutions_pressed() -> void:
	res_opened=true


func _on_RemapDefault_about_to_show() -> void:
	$AudioStreamPlayer.play()


func _on_ChangeKey_about_to_show() -> void:
	$AudioStreamPlayer.play()


func hide_options():
	yield(get_tree().create_timer(0.2),"timeout")
	res_opened=false
	window_opened=false
