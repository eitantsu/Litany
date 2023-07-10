extends Enemy

# Final boss enemy


var facing :=-1
export(float) var speed = 300
export(PackedScene) var projectile
export(NodePath) onready var left = get_node(left).global_position
export(NodePath) onready var right = get_node(right).global_position
export(NodePath) onready var up = get_node(up).global_position

func _ready() -> void:
	player_detected = true
	GameEvents.connect("player_dead",self,"play_sound",["lose"])
	connect("hp_update",self,"check_dead")



func check_dead(hp_change):
	if hp+hp_change<=0:
		GameEvents.emit_signal("boss_dead")

# shoot a projectile
func shoot():
	play_sound("shoot")
	var d = projectile.instance()
	d.damage = damager.damage
	d.direction = (player_data.properties["position"] - position)
	d.speed = 140
	d.move = true
	if facing == -1:
		d.get_child(1).flip_h = true
	get_tree().root.add_child(d)
	d.global_position = global_position 
	d.global_position.y -= half_height

# spell - multiple projectiles
func spell():
	play_sound("spell")
	var d = projectile.instance()
	d.damage = damager.damage
	d.direction = Vector2(0,1)
	d.speed = 140
	d.move = true
	if facing == -1:
		d.get_child(1).flip_h = true
	get_tree().root.add_child(d)
	d.global_position = global_position 
	d.global_position.y -= half_height
	
	var d2 = projectile.instance()
	d2.damage = damager.damage
	d2.direction = Vector2(1,1)
	d2.speed = 140
	d2.move = true
	if facing == -1:
		d2.get_child(1).flip_h = true
	get_tree().root.add_child(d2)
	d2.global_position = global_position + Vector2(30,0)
	d2.global_position.y -= half_height

	var d3 = projectile.instance()
	d3.damage = damager.damage
	d3.direction = Vector2(-1,1)
	d3.speed = 140
	d3.move = true
	if facing == -1:
		d3.get_child(1).flip_h = true
	get_tree().root.add_child(d3)
	d3.global_position = global_position + Vector2(-30,0)
	d3.global_position.y -= half_height


export(Array,AudioStream) var hit
export(Array,AudioStream) var dead
export(Array,AudioStream) var spell
export(Array,AudioStream) var shoot
export(Array,AudioStream) var melee
export(Array,AudioStream) var start
export(Array,AudioStream) var lose

# play requested sound
func play_sound(type):
	var array
	match type:
		"dead":
			array = dead
		"hit":
			array = hit
		"spell":
			array = spell
		"shoot":
			array = shoot
		"melee":
			array = melee
		"start":
			array = start
		"lose":
			array = lose
	if array.empty():
		return
	var i = randi()%array.size()
	$AudioStreamPlayer2D.stream = array[i]
	$AudioStreamPlayer2D.play()

# save enemy stats
func save_self(slot):
	return null

# load enemy
func load_self(slot):
	if not uuid in slot.objects:
		player_detected = false
		GameEvents.emit_signal("boss_dead")
		GameEvents.emit_signal("camera_offset",false)
		queue_free()
	else:
		GameEvents.emit_signal("camera_offset",true)
		play_sound("start")
