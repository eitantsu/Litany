extends Node

# singleton to handle saving/loading and scene changing

onready var save_resource = preload("res://global/save_resource.gd")
onready var player_runtime_data = preload("res://global/player_runtime_data.tres")
onready var inventory = preload("res://global/player_inventory.tres")

onready var item_scene = preload("res://inventory/item.tscn")
onready var uuid_holder = preload("res://global/uuid_holder.tres")

var current_slot = null # current scene is scene last saved or loaded

var destroyed = {} # all the objects that have been destroyed
signal loading_done

# load a given slot
func load_slot(path):
	destroyed = {}
	current_slot = path
	var slot = ResourceLoader.load(path,"",true)

	get_tree().change_scene(slot.current_scene) # change to slot current scene
	yield(GameEvents,"scene_ready")
	yield(get_tree(),"idle_frame") # wait for everything to load so _ready doesnt overwrite changes
	get_tree().paused=false
	var objects = get_tree().get_nodes_in_group("Persist") # call every persistent object load function
	for object in objects:
		object.call("load_self",slot)
	load_instanced(slot) # load objects that were instanced (and thus dont exist yet in the world)
	emit_signal("loading_done")

# save a given slot
func save_slot(path):
	current_slot = path
	var slot = ResourceLoader.load("user://runtime_save.tres","",true)

	# update slot's vars
	slot.current_scene = get_tree().current_scene.filename 
	slot.player_data=player_runtime_data
	slot.player_inventory = inventory
	
	slot.objects={}
	
	# save every persistent object
	var objects = get_tree().get_nodes_in_group("Persist")
	for object in objects:
		var dic = object.call("save_self",slot)
		if dic!=null:
			slot.objects[dic["uuid"]] = dic
	

	# add objects from runtime slot, in case of collision current slot decides
	var runtime_slot = ResourceLoader.load("user://runtime_save.tres","",true)
	for uuid in runtime_slot.objects:
		if not uuid in slot.objects:
			slot.objects[uuid] = runtime_slot.objects[uuid]

	# objects that were destroyed shouldnt be saved
	for uuid in destroyed: 
		slot.objects.erase(uuid)
	
	# save as slot, and runtime
	ResourceSaver.save(path,slot,ResourceSaver.FLAG_BUNDLE_RESOURCES | ResourceSaver.FLAG_REPLACE_SUBRESOURCE_PATHS | ResourceSaver.FLAG_CHANGE_PATH | ResourceSaver.FLAG_RELATIVE_PATHS)
	ResourceSaver.save("user://runtime_save.tres",slot,ResourceSaver.FLAG_BUNDLE_RESOURCES | ResourceSaver.FLAG_REPLACE_SUBRESOURCE_PATHS | ResourceSaver.FLAG_CHANGE_PATH | ResourceSaver.FLAG_RELATIVE_PATHS)

# change scene on request, save temporary data to runtime slot, change, and load back slot
func scene_change(scene_path,zone_id):
	var runtime_slot
	if current_slot!=null: # if current slot was used load it
		runtime_slot = ResourceLoader.load(current_slot,"",true)
	else:
		runtime_slot = save_resource.new()
		var uuids = all_objects() # first time we create a save file we want all objects to be saved first, so they dont get erased
		for uuid in uuids:
			runtime_slot.objects[uuid] = {}
	
	# update slot vars, but change current scene to requested scene
	runtime_slot.current_scene = scene_path 
	runtime_slot.player_data = player_runtime_data
	runtime_slot.player_inventory=inventory

	# save persistent objects
	var objects = get_tree().get_nodes_in_group("Persist")
	for object in objects:
		var dic = object.call("save_self",runtime_slot)
		if dic != null:
			runtime_slot.objects[dic["uuid"]] = dic
	
	# destroyed objects shouldnt be saved
	for uuid in destroyed: 
		runtime_slot.objects.erase(uuid)
	
	# replace runtime slot 
	ResourceSaver.save("user://runtime_save.tres",runtime_slot,ResourceSaver.FLAG_BUNDLE_RESOURCES | ResourceSaver.FLAG_REPLACE_SUBRESOURCE_PATHS | ResourceSaver.FLAG_CHANGE_PATH | ResourceSaver.FLAG_RELATIVE_PATHS) 

	#load runtime back
	load_slot("user://runtime_save.tres")
	yield(self,"loading_done") # wait until loaded new scene
	
	# get entry/exit zone and place player on it, with correct facing
	var scene_zones = get_tree().get_nodes_in_group("SceneZones")
	for zone in scene_zones:
		if zone.my_id == zone_id:
			GameEvents.emit_signal("change_player_pos",zone.pos,zone.facing)

# add to destroyed objects list
func add_destroyed(uuid):
	destroyed[uuid] = ""


# this code generates a random uuid to identify instanced objects

const MODULO_8_BIT = 256

static func getRandomInt():
  randomize()
  return randi() % MODULO_8_BIT

static func uuidbin():
  return [
	getRandomInt(), getRandomInt(), getRandomInt(), getRandomInt(),
	getRandomInt(), getRandomInt(), ((getRandomInt()) & 0x0f) | 0x40, getRandomInt(),
	((getRandomInt()) & 0x3f) | 0x80, getRandomInt(), getRandomInt(), getRandomInt(),
	getRandomInt(), getRandomInt(), getRandomInt(), getRandomInt(),
  ]

static func v4():
  var b = uuidbin()
  return '%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x' % [
	b[0], b[1], b[2], b[3],
	b[4], b[5],
	b[6], b[7],
	b[8], b[9],
	b[10], b[11], b[12], b[13], b[14], b[15]
  ]

#################################################

# load instanced objects
func load_instanced(slot):
	for uuid in slot.objects:
		if slot.objects[uuid].has("instanced"):
			if slot.objects[uuid]["scene"] == get_tree().current_scene.filename:
				var cs = map_classes(slot.objects[uuid]["instanced"])
				var object = cs.instance()
				object.uuid = uuid
				object.load_self(slot)
				get_tree().current_scene.add_child(object)
			

# map packed scenes to string
func map_classes(c_type):
	match c_type:
		"item":
			return item_scene

# reset data of slot
func reset():
	destroyed = {}
	current_slot = null
	inventory.reset()
	player_runtime_data.reset()
	
	# on reset need to immediately create new runtime save, so that all objects with uuids appear in it
	var runtime_slot = save_resource.new()
	var uuids = all_objects() # first time we create a save file we want all objects to be saved first, so they dont get erased
	for uuid in uuids:
		runtime_slot.objects[uuid] = {}
	runtime_slot.current_scene = "nan"
	runtime_slot.player_data = player_runtime_data
	runtime_slot.player_inventory=inventory
	var objects = get_tree().get_nodes_in_group("Persist")
	for object in objects:
		var dic = object.call("save_self",runtime_slot)
		if dic != null:
			runtime_slot.objects[dic["uuid"]] = dic
			
	ResourceSaver.save("user://runtime_save.tres",runtime_slot,ResourceSaver.FLAG_BUNDLE_RESOURCES | ResourceSaver.FLAG_REPLACE_SUBRESOURCE_PATHS | ResourceSaver.FLAG_CHANGE_PATH | ResourceSaver.FLAG_RELATIVE_PATHS)

# if using controller hide mouse
func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion or event is InputEventScreenTouch or event is InputEventScreenDrag:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

# this function retrieves all the objects that are persistent(not including instanced) in the entire game
func all_objects():
	return uuid_holder.uuids

