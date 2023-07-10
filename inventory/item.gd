extends Area2D

# item logic

class_name Item

export(Resource) var item_resource = item_resource as ItemResource
export(Resource) var player_runtime_data = player_runtime_data as PlayerRuntimeData
export(Resource) var inv = inv as InventoryResource
export(NodePath) onready var inv_full_message = get_node(inv_full_message) as Label

var player_inside :=false
export(String) var uuid # unique id
var instanced := false # if is dropped from an enemy
export(float) var grav := 30

func _ready() -> void:
	$Sprite.texture = item_resource.texture

# when player picks it up logic
func pickup():
	var areas = get_overlapping_areas()
	for area in areas:
		if area.get_collision_layer_bit(2): # if closer to player allow pickup
			if area.position.distance_to(player_runtime_data.properties["position"]) < position.distance_to(player_runtime_data.properties["position"]):
				return
	if inv.inventory.size() < inv.max_size: # if inventory not full allow pickup
		GameEvents.emit_signal("picked_item",item_resource)
		SceneManager.add_destroyed(uuid)
		queue_free()
	else:
		inv_full_message.show() # show that inventory is full
		yield(get_tree().create_timer(1.5),"timeout")
		inv_full_message.hide()

# when player nearby, if instant use it, else allow it to be interacted with
func _on_Item_body_entered(body: Node) -> void:
	# if not player ignore
	if body.get_collision_layer_bit(1): return
	if body.get_collision_layer_bit(2): return
	if body.get_collision_layer_bit(3): return
	if body.get_collision_layer_bit(4): return
	if body.get_collision_layer_bit(5): return
	
	# if instant update and destroy self
	if item_resource.type == GlobalVariables.ItemTypes.INSTANT:
		for property in item_resource.properties:
			if property!="eq_type":
				GameEvents.emit_signal(property+"_update",item_resource.properties[property])
			SceneManager.add_destroyed(uuid)
		GameEvents.emit_signal("instanced_item_pick")
		queue_free()
	else:
		player_inside = true
		GameEvents.connect("pressed_interact",self,"pickup")

# player left, no loger interactable
func _on_Item_body_exited(body: Node) -> void:
	player_inside = false
	if GameEvents.is_connected("pressed_interact",self,"pickup"):
		GameEvents.disconnect("pressed_interact",self,"pickup")

# save the item state
func save_self(slot):
	var dic = {}
	dic["uuid"] = uuid
	dic["scene"] = get_tree().current_scene.filename
	dic["resource"] = item_resource
	dic["position"] = position + Vector2(0, -15)
	if instanced:
		dic["instanced"] = "item"
	return dic

# load the item state
func load_self(slot):
	if not uuid in slot.objects:
		 queue_free()
	else:
		if "position" in slot.objects[uuid]:
			position = slot.objects[uuid]["position"]
		if "resource" in slot.objects[uuid]:
			item_resource = slot.objects[uuid]["resource"]
		if "instanced" in slot.objects[uuid]:
			instanced = true
		set_process(true)

# continously push the item onto ground
func _process(delta: float) -> void:
	var bodies =  $DetectGround.get_overlapping_bodies()
	for body in bodies:
		if body.get_collision_layer_bit(1): # if touched ground, no longer move it down
			set_process(false)
	var velocity = Vector2.DOWN * grav
	position += velocity * delta

func set_new():
	$Sprite.texture=item_resource.texture
