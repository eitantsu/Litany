extends Enemy

# an extension to enemy, moves in a simple patrol between 2 points
var facing :=-1
export(float) var speed = 300
export(float) var gravity = 50
export(NodePath) onready var left = get_node(left).global_position
export(NodePath) onready var right = get_node(right).global_position
export(NodePath) onready var top = get_node(top) as Area2D

func _ready() -> void:
	randomize()
	var f = randi() %2
	if f == 1:
		facing = -1
	else:
		flip()
		facing = 1

# if player jumps on top of enemy destroy self
func _on_TopJumpArea_body_entered(body: Node) -> void:
	if body.get_collision_layer_bit(0):
		if body.position.y > top.global_position.y: # prevent body entered from below
			return
		$Damager/CollisionShape2D.set_deferred("disabled",true)
		if dropped_item!=null:
			var itemd = item_scene.instance()
			itemd.instanced = true
			itemd.item_resource = dropped_item
			itemd.position = global_position
			itemd.uuid = SceneManager.v4()
			get_tree().current_scene.call_deferred("add_child",itemd)
		SceneManager.add_destroyed(uuid)
		queue_free()


export(Array,AudioStream) var hit
export(Array,AudioStream) var dead

# play requested sound
func play_sound(type):
	var array
	match type:
		"dead":
			array = dead
		"hit":
			array = hit
	if array.empty():
		return
	var i = randi()%array.size()
	$AudioStreamPlayer2D.stream = array[i]
	$AudioStreamPlayer2D.play()

# save enemy stats
func save_self(slot):
	var dic = {}
	dic["uuid"] = uuid
	dic["hp"] = hp
	dic["position"] = position
	dic["left"] = left
	dic["right"] = right
	dic["facing"] = facing
	return dic

# load enemy
func load_self(slot):
	if not uuid in slot.objects:
		queue_free()
	else:
		if "hp" in slot.objects[uuid]:
			hp = slot.objects[uuid]["hp"]
		if "position" in slot.objects[uuid]:
			position = slot.objects[uuid]["position"]
		if "right" in slot.objects[uuid]:
			right = slot.objects[uuid]["right"]
			get_node("Right").global_position=right
		if "left" in slot.objects[uuid]:
			left = slot.objects[uuid]["left"]
			get_node("Left").global_position=left
		if "facing" in slot.objects[uuid]:
			facing = slot.objects[uuid]["facing"]
			if facing==-1 and $Position2D.scale.x!=1 : flip()
			elif facing==1 and $Position2D.scale.x!=-1 : flip()
