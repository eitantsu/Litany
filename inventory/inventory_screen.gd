extends Popup

# equipment screen logic

export(Resource) var player_runtime_data = player_runtime_data as PlayerRuntimeData
export(Resource) var inventory_resource = inventory_resource as InventoryResource

export(NodePath) onready var hp_bar = get_node(hp_bar) as TextureProgress
export(NodePath) onready var strength_l = get_node(strength_l) as Label
export(NodePath) onready var defense_l = get_node(defense_l) as Label
export(NodePath) onready var item_options = get_node(item_options) as PopupMenu
export(NodePath) onready var items_list = get_node(items_list) as ItemList
export(NodePath) onready var exit = get_node(exit) as Button

export(NodePath) onready var accessory = get_node(accessory) as MenuButton
export(NodePath) onready var helmet = get_node(helmet) as MenuButton
export(NodePath) onready var armour = get_node(armour) as MenuButton
export(NodePath) onready var boots = get_node(boots) as MenuButton
export(Texture) var default_texture

var current_item_idx = null
var current_item = null

var strength := 10.0
var defense := 10.0

var hp := 100

func _ready() -> void:
	GameEvents.connect("hp_update",self,"hp_update")
	GameEvents.connect("strength_update",self,"strength_update")
	GameEvents.connect("defense_update",self,"defense_update")
	GameEvents.connect("show_inventory",self,"popup_centered")
	GameEvents.connect("item_add",self,"item_add")
	GameEvents.connect("item_remove",self,"item_remove")
	GameEvents.connect("equip",self,"equip")
	GameEvents.connect("unequip",self,"unequip")
	accessory.get_popup().connect("index_pressed",self,"equipment_activated",[GlobalVariables.EquipmentTypes.ACCESSORY])
	helmet.get_popup().connect("index_pressed",self,"equipment_activated",[GlobalVariables.EquipmentTypes.HELMET])
	armour.get_popup().connect("index_pressed",self,"equipment_activated",[GlobalVariables.EquipmentTypes.ARMOUR])
	boots.get_popup().connect("index_pressed",self,"equipment_activated",[GlobalVariables.EquipmentTypes.BOOTS])
	accessory.connect("toggled",self,"disable_clicktrough",[GlobalVariables.EquipmentTypes.ACCESSORY])
	helmet.connect("toggled",self,"disable_clicktrough",[GlobalVariables.EquipmentTypes.HELMET])
	armour.connect("toggled",self,"disable_clicktrough",[GlobalVariables.EquipmentTypes.ARMOUR])
	boots.connect("toggled",self,"disable_clicktrough",[GlobalVariables.EquipmentTypes.BOOTS])
	
	hp_bar.value = 100
	strength_l.text="Strength: "+str(strength)
	defense_l.text="Defense: "+str(defense)

	accessory.icon = default_texture
	accessory.text = "Empty"
	helmet.icon = default_texture
	helmet.text = "Empty"
	armour.icon = default_texture
	armour.text = "Empty"
	boots.icon = default_texture
	boots.text = "Empty"

# update hp bar
func hp_update(hp_change):
	if hp_change<0:
		hp_change+=defense
		if hp_change>=0:
			hp_change = -1
	hp += hp_change
	hp = clamp(hp,0,100)
	hp_bar.value = hp

# update strength text
func strength_update(str_change):
	strength+=str_change
	strength_l.text = "Strength: "+str(strength)

# update defense text
func defense_update(def_change):
	defense+=def_change
	defense_l.text = "Defense: "+str(defense)

# hide inventory screen
func _on_Exit_pressed() -> void:
	$AudioStreamPlayer.play()
	hide()
	GameEvents.emit_signal("hide_blur")

# what action to do with the item (equip,discard,use)
func _on_ItemOptions_index_pressed(index: int) -> void:
	$AudioStreamPlayer.play()
	if index == 0:
		if current_item.type == GlobalVariables.ItemTypes.CONSUMABLE:
			for property in current_item.properties:
				if property!="eq_type":
					GameEvents.emit_signal(property+"_update",current_item.properties[property])
				inventory_resource.item_remove(current_item_idx)
		else:
			inventory_resource.equip(current_item_idx)
	elif index == 1:
		inventory_resource.item_remove(current_item_idx)


# show item options popup
func _on_Items_item_activated(index: int) -> void:
	item_options.rect_position = Vector2(items_list.rect_position.x+items_list.rect_size.x, items_list.rect_position.y+index*items_list.get_item_icon(index).get_height())
	current_item_idx = index
	current_item = inventory_resource.inventory[index]
	if current_item.type == GlobalVariables.ItemTypes.EQUIPMENT:
		item_options.set_item_text(0, "Equip")
	else:
		item_options.set_item_text(0, "Use")
	item_options.popup()

# add item to list
func item_add(item):
	if item==null: return
	items_list.add_item(item.iname,item.texture)
	var num = items_list.get_item_count()
	items_list.set_item_tooltip_enabled(num-1,false)

# remove item from list
func item_remove(idx):
	items_list.remove_item(idx)

# equip item and put it in the correct equipment slot
func equip(item):
	if item.properties["eq_type"] == GlobalVariables.EquipmentTypes.ACCESSORY:
		accessory.text = item.iname
		accessory.icon = item.texture
	elif item.properties["eq_type"] == GlobalVariables.EquipmentTypes.HELMET:
		helmet.text = item.iname
		helmet.icon = item.texture
	elif item.properties["eq_type"] == GlobalVariables.EquipmentTypes.ARMOUR:
		armour.text = item.iname
		armour.icon = item.texture
	elif item.properties["eq_type"] == GlobalVariables.EquipmentTypes.BOOTS:
		boots.text = item.iname
		boots.icon = item.texture
	# update stats
	if "strength" in item.properties: GameEvents.emit_signal("strength_update",item.properties.get("strength",0))
	if "defense" in item.properties: GameEvents.emit_signal("defense_update",item.properties.get("defense",0))

# decide to either discard or unequip the equipment
func equipment_activated(index,type):
	$AudioStreamPlayer.play()
	if index == 0:
		inventory_resource.unequip(type,false)
	else:
		inventory_resource.unequip(type,true)

# disable buttons so cant click "thorugh" the popup
func disable_clicktrough(is_up,type):
	if is_up:
		if type == GlobalVariables.EquipmentTypes.ACCESSORY:
			helmet.disabled = true
			armour.disabled = true
			boots.disabled = true
		elif type == GlobalVariables.EquipmentTypes.HELMET:
			accessory.disabled = true
			armour.disabled = true
			boots.disabled = true
		elif type == GlobalVariables.EquipmentTypes.ARMOUR:
			helmet.disabled = true
			accessory.disabled = true
			boots.disabled = true
		elif type == GlobalVariables.EquipmentTypes.BOOTS:
			helmet.disabled = true
			armour.disabled = true
			accessory.disabled = true
	else:
		helmet.disabled = false
		accessory.disabled = false
		boots.disabled = false
		armour.disabled = false

# reset the equipment slot
func unequip(type):
	if type == GlobalVariables.EquipmentTypes.ACCESSORY:
		accessory.icon = default_texture
		accessory.text = "Empty"
	elif type == GlobalVariables.EquipmentTypes.HELMET:
		helmet.icon = default_texture
		helmet.text = "Empty"
	elif type == GlobalVariables.EquipmentTypes.ARMOUR:
		armour.icon = default_texture
		armour.text = "Empty"
	elif type == GlobalVariables.EquipmentTypes.BOOTS:
		boots.icon = default_texture
		boots.text = "Empty"

func _on_InventroyScreen_hide() -> void:
	$AudioStreamPlayer.play()
	get_tree().paused = false
	GameEvents.emit_signal("hide_blur")

func save_self(slot):
	pass

# load saved inventory inside the slot into runtime inventory, and set properties by it.
func load_self(slot):
	inventory_resource.inventory.clear()

	inventory_resource.accessory = slot.player_inventory.accessory
	inventory_resource.helmet = slot.player_inventory.helmet
	inventory_resource.armour = slot.player_inventory.armour
	inventory_resource.boots = slot.player_inventory.boots
	
	if inventory_resource.accessory != null:
		accessory.icon = inventory_resource.accessory.texture
		accessory.text = inventory_resource.accessory.iname
	if inventory_resource.helmet != null:
		helmet.icon = inventory_resource.helmet.texture
		helmet.text = inventory_resource.helmet.iname
	if inventory_resource.armour != null:
		armour.icon = inventory_resource.armour.texture
		armour.text = inventory_resource.armour.iname
	if inventory_resource.boots != null:
		boots.icon = inventory_resource.boots.texture
		boots.text = inventory_resource.boots.iname
		
	strength = slot.player_data.properties["strength"]
	defense = slot.player_data.properties["defense"]
	hp_bar.value = slot.player_data.properties["hp"]
	hp = slot.player_data.properties["hp"]
	
	defense_l.text = "Defense: "+str(defense)
	strength_l.text = "Strength: "+str(strength)

	items_list.clear()
	for item in slot.player_inventory.inventory:
		inventory_resource.item_add(item)
	
	var num = items_list.get_item_count()
	for i in range(num):
		items_list.set_item_tooltip_enabled(i,false)
	
	if slot.player_inventory.accessory == null:
		accessory.icon = default_texture
		accessory.text = "Empty"
	if slot.player_inventory.helmet == null:
		helmet.icon = default_texture
		helmet.text = "Empty"
	if slot.player_inventory.armour == null:
		armour.icon = default_texture
		armour.text = "Empty"
	if slot.player_inventory.boots == null:
		boots.icon = default_texture
		boots.text = "Empty"

var last_item = null

# double press for touchscreens
func _on_Items_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.is_pressed():
		var it = items_list.get_item_at_position(event.position,true)
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


func _on_ItemOptions_popup_hide() -> void:
	$AudioStreamPlayer.play()


func _on_InventroyScreen_visibility_changed() -> void:
	if visible:
		pass


func _on_ItemOptions_about_to_show() -> void:
	$AudioStreamPlayer.play()
