extends Enemy

# special enemy that tracks player's position and moves towards him in air

var speed = 60
export(NodePath) onready var top = get_node(top) as Area2D
var facing:=-1

# when player jumps on top destroy self
func _on_TopJumpArea_body_entered(body: Node) -> void:
	if body.get_collision_layer_bit(0):
		if body.position.y > top.global_position.y: # prevent body entered from below
			return
		GameEvents.emit_signal("is_player_detected",false)
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
