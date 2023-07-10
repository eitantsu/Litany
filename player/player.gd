extends KinematicBody2D

# all the logic of the player character

class_name Player

export(Resource) var player_runtime_data = player_runtime_data as PlayerRuntimeData
export(Resource) var inventory_resource = inventory_resource as InventoryResource

export(String) var uuid # unique id
export var speed :float = 300
export var gravity :float = 55
export var jump :float = 600
var max_angle := 70
var velocity := Vector2()
var default_hp :=100
var hp :=100
var default_strength :=10
var default_defense :=10
var strength :=10
var defense :=10
onready var half_height = $CollisionShape2D.shape.height
export(NodePath) onready var damager = get_node(damager) as Damager
export(PackedScene) var projectile

func _ready() -> void:
	GameEvents.connect("camera_offset",self,"camera_offset")
	GameEvents.connect("picked_item",self,"picked_item")
	GameEvents.connect("hp_update",self,"hp_update")
	GameEvents.connect("strength_update",self,"strength_update")
	GameEvents.connect("defense_update",self,"defense_update")
	GameEvents.connect("change_player_pos",self,"change_pos")
	GameEvents.connect("instanced_item_pick",self,"interact_sound")
	damager.damage = strength
	player_runtime_data.properties["position"] = position
	
func camera_offset(o):
	if o:
		$Camera2D.offset.y-=40
	else:
		$Camera2D.offset.y=0

# flip the sprite
func flip():
	if $Position2D.scale.x > 0:
		$Position2D.scale.x = -1
	else:
		$Position2D.scale.x = 1

# get sprite facing
func get_facing():
	var facing = $Position2D.scale.x
	return facing

# get movement direction
func get_direction():
	return Input.get_action_strength("right") - Input.get_action_strength("left")

# returns direction of wall that player collides with, if exists
func get_wall_collided():
	var collision :Dictionary = raycast_shape(Vector2(4,0))
	if(not collision.empty()):
		var angle = abs(rad2deg(collision["normal"].angle_to(Vector2.UP)))
		if(angle > max_angle): 
			return 1
			
	collision = raycast_shape(Vector2(-4,0))
	if(not collision.empty()):
		var angle = abs(rad2deg(collision["normal"].angle_to(Vector2.UP)))
		if(angle > max_angle): 
			return -1
			
	return 0

# checks if player is on a floor (including low slopes)
func on_floor():
	if is_on_floor(): return true
	var collision :Dictionary = raycast_shape(Vector2(0,-4))
	if collision.empty(): return false
	var angle = abs(rad2deg(collision["normal"].angle_to(Vector2.UP)))
	if(angle <= max_angle): return true
	return false

# casts a capsule towards a point and returns a collision data if collided with anything along the way
func raycast_shape(to :Vector2) -> Dictionary:
	var space_rid = get_world_2d().space
	var space_state = Physics2DServer.space_get_direct_state(space_rid)
	
	var capsule := CapsuleShape2D.new()
	capsule.radius = $CollisionShape2D.shape.radius
	capsule.height = $CollisionShape2D.shape.height

	var shape := Physics2DShapeQueryParameters.new()
	shape.set_shape(capsule)
	shape.collision_layer = collision_mask
	shape.exclude = [self,$CollisionShape2D]
	shape.set_transform($CollisionShape2D.global_transform)

	shape.motion=to
	var arr = space_state.cast_motion(shape)
	if ((arr[0] == arr[1]) and arr[0] == 1):
		return space_state.get_rest_info(shape)
		
	var frac=arr[1]
	#shape.motion*=frac
	#var point=space_state.collide_shape(shape)[0]

	var temp=$CollisionShape2D.global_transform
	temp.origin += to*frac
	shape.set_transform(temp)
	var collision = space_state.get_rest_info(shape)
	return collision

# updates own hp, if negative change - dont allow damage for a while and visually show it
func hp_update(hp_change):
	if hp_change<0:
		hp_change+=defense
		if hp_change>=0: hp_change=-1 # if too much defense, allow atleast 1 point of damage
	hp += hp_change
	hp = clamp(hp,0,100)
	player_runtime_data.properties["hp"] = hp
	if hp<=0 or player_runtime_data.properties["state"]==GlobalVariables.States.DEAD:
		pass # dead
	if hp_change<0:
		play_sound("hit")
		# visual cue, and dont allow more damage for a time
		$Position2D/Sprite.modulate = Color(0.7,0,0)
		$DamageArea.disconnect("area_entered",self,"_on_DamageArea_area_entered")
		yield(get_tree().create_timer(2),"timeout")
		$DamageArea.connect("area_entered",self,"_on_DamageArea_area_entered")
		$Position2D/Sprite.modulate = Color(1,1,1)

# add picked item to inventory
func picked_item(item):
	play_sound("interact")
	inventory_resource.item_add(item)

# continously update stats in runtime data every frame
func _process(delta: float) -> void:
	player_runtime_data.properties["position"] =  position
	player_runtime_data.properties["state"] = GlobalVariables.States[$StateMachine.current_state.name.to_upper()]
	player_runtime_data.properties["hp"] = hp
	player_runtime_data.properties["strength"] = strength
	player_runtime_data.properties["defense"] = defense
	# specifically for the first frame, allows other nodes to wait until actual data exists
	GameEvents.emit_signal("player_ready") 

# handling input like - open inventory, pause menu
func _unhandled_input(event: InputEvent) -> void:
	if hp<=0 or player_runtime_data.properties["state"]==GlobalVariables.States.DEAD:
		return
	if event.is_action_pressed("ui_cancel"):
		if player_runtime_data.properties["state"]!=GlobalVariables.States.DIALOGUE:
			play_sound("menus")
			get_tree().paused=true
			GameEvents.emit_signal("show_pause")
	elif event.is_action_pressed("open_inventory"):
		if player_runtime_data.properties["state"]!=GlobalVariables.States.DIALOGUE:
			play_sound("menus")
			get_tree().paused = true
			GameEvents.emit_signal("show_inventory")

# update own strength and add the change to player's damager
func strength_update(str_change):
	strength += str_change
	player_runtime_data.properties["strength"] = strength
	damager.damage+=str_change

# update own defense
func defense_update(def_change):
	defense += def_change
	player_runtime_data.properties["defense"] = defense

# save facing
func save_self(slot):
	var dic = {}
	dic["uuid"] = uuid
	dic["facing"] = $Position2D.scale.x
	return dic

# load up saved stats
func load_self(slot):
	position = slot.player_data.properties["position"]
	hp = slot.player_data.properties["hp"]
	strength = slot.player_data.properties["strength"]
	defense = slot.player_data.properties["defense"]
	damager.damage = slot.player_data.properties["strength"]
	if slot.objects[uuid]["facing"]!=1: flip()

# on contact, damage ourselves
func _on_DamageArea_area_entered(area: Area2D) -> void:
	if area.get_collision_layer_bit(4): # is from enemy?
		if not area.get_collision_mask_bit(3):
			GameEvents.emit_signal("hp_update",-area.damage)

# reset damager position and disable it
func reset_damager():
	damager.position = Vector2.ZERO
	damager.get_child(0).disabled = true

# create a projectile damager with movement
func fire():
	var d = projectile.instance()
	d.damage+=strength
	d.direction = get_facing() * Vector2(1,0)
	d.speed = 140
	d.move = true
	if get_facing() == -1:
		d.get_child(1).flip_h = true
	get_tree().root.add_child(d)
	d.global_position = global_position 
	d.global_position.y -= half_height

# pause game
func call_pause():
	get_tree().paused = true

# when changing scenes through zones, we use this to put player at correct position and facing
func change_pos(pos,fac):
	global_position = pos
	if fac!=get_facing():
		flip()

# if at any point, we are already overlapping with a damager -
# (which didnt damage already because didnt trigger entry zone), damage ourselves
func _physics_process(delta: float) -> void:
	if $Position2D/Sprite.modulate == Color(1,1,1):
		var areas = $DamageArea.get_overlapping_areas()
		for area in areas:
			if area.get_collision_layer_bit(4):
				if not area.get_collision_mask_bit(3):
					GameEvents.emit_signal("hp_update",-area.damage)
					break

# lists of sounds player character uses
export(Array,AudioStream) var jump_sounds
export(Array,AudioStream) var melee
export(Array,AudioStream) var ranged
export(Array,AudioStream) var interact
export(Array,AudioStream) var dead
export(Array,AudioStream) var hit
export(Array,AudioStream) var menus

# play random sound from the requested list
func play_sound(type):
	var array
	match type:
		"jump":
			array = jump_sounds
		"melee":
			array = melee
		"ranged":
			array = ranged
		"interact":
			array = interact
		"dead":
			array = dead
		"hit":
			array = hit
		"menus":
			array = menus
	if array.empty():
		return
	var i = randi()%array.size()
	$AudioStreamPlayer2D.stream = array[i]
	$AudioStreamPlayer2D.play()

func interact_sound():
	play_sound("interact")
