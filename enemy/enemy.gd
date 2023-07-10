extends KinematicBody2D

# enemy logic code

class_name Enemy

signal hp_update


export(String) var uuid # unique id
export(float) var hp = 100
var player_inside := false # if player inside region. not neccessarily detected
var player_detected :=false
export(float) var damage

export(Resource) var dropped_item = dropped_item as ItemResource # enemy can drop item on death

export(NodePath) onready var hp_bar = get_node(hp_bar) as TextureProgress
export(NodePath) onready var damage_area = get_node(damage_area) as Area2D
export(NodePath) onready var distance_area = get_node(distance_area) as Area2D
export(NodePath) onready var timer = get_node(timer) as Timer
export(PackedScene) var item_scene
export(Resource) var player_data = player_data as PlayerRuntimeData
export(NodePath) onready var anim_p = get_node(anim_p) as AnimationPlayer
onready var navigation = get_parent() as Navigation2D
export(bool) var damage_on_collsiion := false # if enemy damages player just by touching
export(bool) var can_track := false # move towards player
export(NodePath) onready var damager = get_node(damager) as Damager

onready var half_height = $CollisionShape2D.shape.height

func _ready() -> void:
	hp_bar.value=hp
	hp_bar.max_value = hp
	connect("hp_update",self,"hp_update")
	# if damage_on_collsiion:
	damage_area.connect("area_entered",self,"_on_DamageArea_area_entered")
	damager.damage = damage
	if can_track:
		damage_area.connect("body_entered",self,"body_entered")
		distance_area.connect("body_entered",self,"_on_PlayerDistanceArea_body_entered")
		distance_area.connect("body_exited",self,"_on_PlayerDistanceArea_body_exited")
		timer.connect("timeout",self,"_on_Timer_timeout")

# update own hp
func hp_update(hp_change):
	hp+=hp_change
	if not hp<=0: play_sound("hit")
	hp_bar.value+=hp_change
	if(hp<=0):
		if player_detected:
			GameEvents.emit_signal("is_player_detected",false)
		play_sound("dead")
		yield(get_tree().create_timer(0.2),"timeout")
		# drop item
		if dropped_item!=null:
			var itemd = item_scene.instance()
			itemd.instanced = true
			itemd.item_resource = dropped_item
			itemd.set_new()
			itemd.position = global_position
			itemd.uuid = SceneManager.v4()
			get_tree().current_scene.call_deferred("add_child",itemd)
		SceneManager.add_destroyed(uuid)
		queue_free()

# save enemy stats
func save_self(slot):
	var dic = {}
	dic["uuid"] = uuid
	dic["hp"] = hp
	dic["position"] = position
	return dic

# load enemy stats
func load_self(slot):
	if not uuid in slot.objects:
		queue_free()
	else:
		if "hp" in slot.objects[uuid]:
			hp = slot.objects[uuid]["hp"]
		if "position" in slot.objects[uuid]:
			position = slot.objects[uuid]["position"]

# player is inside certain range
func _on_PlayerDistanceArea_body_entered(body: Node) -> void:
	if body.get_collision_layer_bit(0):
		var pos = player_data.properties["position"]
		if path_to_player_reachable(): # if player is behind wall for example, dont count that
			player_inside = true

# player left, give some time until enemy will "forget" about him
func _on_PlayerDistanceArea_body_exited(body: Node) -> void:
	if body.get_collision_layer_bit(0):
		player_inside = false
		if player_detected:
			timer.start()  

# damage the player
func _on_DamageArea_area_entered(area: Area2D) -> void:
	if area.get_collision_mask_bit(3) and not area.get_collision_layer_bit(0):
		if not player_detected and can_track:
			player_detected = true
			GameEvents.emit_signal("is_player_detected",true)
		emit_signal("hp_update",-area.damage)

# timeout, enemy forgets player and resumes normal behavior
func _on_Timer_timeout() -> void:
	player_detected = false
	GameEvents.emit_signal("is_player_detected",false)

# check if player is infront of enemy but wasnt detected before
func _physics_process(delta: float) -> void:
	var facing_right = ($Position2D.scale.x == -1)
	if player_inside:
		if facing_right and path_to_player_reachable() and player_side()==1:
			if not player_detected and can_track:
				player_detected = true
				GameEvents.emit_signal("is_player_detected",true)
		if not facing_right and path_to_player_reachable() and player_side()==-1:
			if not player_detected and can_track:
				player_detected = true
				GameEvents.emit_signal("is_player_detected",true)

# check if can  navgiate to player position
func path_to_player_reachable():
	var pos = player_data.properties["position"]
	var path = navigation.get_simple_path(position,pos)
	if  pos in path:
		return true
	else: return false

# get relative player position
func player_side():
	if player_data.properties["position"].x >= position.x:
		return 1
	else:
		return -1

# cast a ray and return collision
func raycast(from,to,mask):
	var space_rid = get_world_2d().space
	var space_state = Physics2DServer.space_get_direct_state(space_rid)
	var dic = space_state.intersect_ray(from,to,[self,damage_area.get_child(0),distance_area.get_child(0),$CollisionShape2D],mask)
	return dic

# cast a shape, return collision
func shapecast(to):
	var space_rid = get_world_2d().space
	var space_state = Physics2DServer.space_get_direct_state(space_rid)
	
	var capsule := CapsuleShape2D.new()
	capsule.radius = $CollisionShape2D.shape.radius
	capsule.height = $CollisionShape2D.shape.height

	var shape := Physics2DShapeQueryParameters.new()
	shape.set_shape(capsule)
	shape.collision_layer = pow(2, 1)#collision_mask
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

# check if on floor
func on_floor():
	if is_on_floor(): return true
	var collision :Dictionary = shapecast(Vector2(0,-4))
	if collision.empty(): return false
	var angle = abs(rad2deg(collision["normal"].angle_to(Vector2.UP)))
	if(angle <= 46): return true
	return false

# flip sprite
func flip():
	$Position2D.scale.x *=-1

func play_sound(x):
	pass

# if player collided make detected
func body_entered(body):
	if body.get_collision_layer_bit(0):
		if not player_detected and can_track:
			player_detected = true
			GameEvents.emit_signal("is_player_detected",true)
