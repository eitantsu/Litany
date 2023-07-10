extends TouchScreenButton

# mobile touch joystick logic

onready var center = Vector2(normal.get_width()/2,normal.get_height()/2) # center of texture
onready var half_width = shape.radius

var drag= false # is dragging joystick?
var released = true # joystick released?

func _input(event: InputEvent) -> void:
	# if not touching, release
	if (event is InputEventScreenTouch and not event.is_pressed() and event.index==0):
		released = true 
		reset(0)
	elif drag and ((event is InputEventScreenTouch and is_pressed() and event.index==0) or (event is InputEventScreenDrag and event.index==0)):
		var move_vector = (event.position - (position+center)).normalized()
		
		# calculate joystick movement and feed event to move the player
		var event1 = InputEventJoypadMotion.new() 
		event1.axis = JOY_AXIS_0
		if move_vector.x>=0.5:
			event1.axis_value = 1.0
		elif move_vector.x<=-0.5:
			event1.axis_value = -1.0
		Input.parse_input_event(event1)
		var event2 = InputEventJoypadMotion.new()
		event2.axis = JOY_AXIS_1
		if move_vector.y>=0.5:
			event2.axis_value = 1
		elif move_vector.y<=-0.5:
			event2.axis_value = -1
		Input.parse_input_event(event2)

		# calculate relative joystick position
		var relative_x=clamp(abs((event.position.x-(position.x+center.x)))/half_width, 0, 1)
		if event.position.x < position.x+center.x:
			relative_x*=-1
		var relative_y=clamp(abs((event.position.y-(position.y+center.y)))/half_width, 0, 1)
		if event.position.y < position.y+center.y:
			relative_y*=-1
		
		# update sprite position to match the touch event
		var newpos_local = Vector2(relative_x*half_width,relative_y*half_width)
		var newpos_global = newpos_local+Vector2($Position2D.global_position)
		
		# joystick is dragged outside bounding circle, put sprite on edge
		if newpos_global.distance_to($Position2D.global_position) > half_width: 
			$Position2D/Sprite.position = (half_width/newpos_global.distance_to($Position2D.global_position))*newpos_local
		# else poition is inside bounding region
		else: 
			$Position2D/Sprite.position=newpos_local


# on release, relase joystick
func _on_TouchScreenButton_released() -> void:
	if released:
		reset(0)

func _on_Joystick_pressed() -> void:
	released = false
	drag = true

# reset joystick position
func reset(x=0):
	released = true
	drag = false
	var event1 = InputEventJoypadMotion.new()
	event1.axis = JOY_AXIS_0
	event1.axis_value = 0
	Input.parse_input_event(event1)
	var event2 = InputEventJoypadMotion.new()
	event2.axis = JOY_AXIS_1
	event2.axis_value = 0
	Input.parse_input_event(event2)
	# reset sprite to center
	$Position2D/Sprite.position=Vector2.ZERO

func _ready() -> void:
	if OS.get_name()!="Android":
		hide()
	GameEvents.connect("player_dead",self,"hide")
	GameEvents.connect("show_death",self,"reset")
	GameEvents.connect("show_inventory",self,"reset")
	GameEvents.connect("show_pause",self,"reset")
	GameEvents.connect("start_dialogue",self,"reset")
