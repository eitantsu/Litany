extends Resource

# inventory resource for player logic

class_name InventoryResource

# can hold items, and 4 equiped
export(Array, Resource) var inventory
export(int) var max_size := 10
export(Resource) var accessory = null
export(Resource) var helmet = null
export(Resource) var armour = null
export(Resource) var boots = null

# equip an item from the inventory
func equip(idx):
	var equipped_item = null
	if inventory[idx].properties["eq_type"] == GlobalVariables.EquipmentTypes.ACCESSORY:
		if accessory != null:
			equipped_item = accessory
			if "strength" in accessory.properties: GameEvents.emit_signal("strength_update",-accessory.properties.get("strength",0))
			if "defense" in accessory.properties: GameEvents.emit_signal("defense_update",-accessory.properties.get("defense",0))
		accessory = inventory[idx]
	if inventory[idx].properties["eq_type"] == GlobalVariables.EquipmentTypes.HELMET:
		if helmet != null:
			equipped_item = helmet
			if "strength" in helmet.properties: GameEvents.emit_signal("strength_update",-helmet.properties.get("strength",0))
			if "defense" in helmet.properties: GameEvents.emit_signal("defense_update",-helmet.properties.get("defense",0))
		helmet = inventory[idx]
	if inventory[idx].properties["eq_type"] == GlobalVariables.EquipmentTypes.ARMOUR:
		if armour != null:
			equipped_item = armour
			if "strength" in armour.properties: GameEvents.emit_signal("strength_update",-armour.properties.get("strength",0))
			if "defense" in armour.properties: GameEvents.emit_signal("defense_update",-armour.properties.get("defense",0))
		armour = inventory[idx]
	if inventory[idx].properties["eq_type"] == GlobalVariables.EquipmentTypes.BOOTS:
		if boots != null:
			equipped_item = boots
			if "strength" in boots.properties: GameEvents.emit_signal("strength_update",-boots.properties.get("strength",0))
			if "defense" in boots.properties: GameEvents.emit_signal("defense_update",-boots.properties.get("defense",0))
		boots = inventory[idx]
	GameEvents.emit_signal("equip",inventory[idx])
	item_remove(idx)
	
	# if replaced other equipment add it back
	if (equipped_item!=null):
		item_add(equipped_item)

# unequip item of some type, choose wheter to re-add to inventory or discard completely
func unequip(type, discard):
	if type == GlobalVariables.EquipmentTypes.ACCESSORY:
		if accessory==null: return
		var item = accessory
		if "strength" in item.properties: GameEvents.emit_signal("strength_update",-item.properties.get("strength",0))
		if "defense" in item.properties: GameEvents.emit_signal("defense_update",-item.properties.get("defense",0))
		accessory = null
		if(not discard): item_add(item)
	elif type == GlobalVariables.EquipmentTypes.HELMET:
		if helmet==null: return
		var item = helmet
		if "strength" in item.properties: GameEvents.emit_signal("strength_update",-item.properties.get("strength",0))
		if "defense" in item.properties: GameEvents.emit_signal("defense_update",-item.properties.get("defense",0))
		helmet = null
		if(not discard): item_add(item)
	elif type == GlobalVariables.EquipmentTypes.ARMOUR:
		if armour==null: return
		var item = armour
		if "strength" in item.properties: GameEvents.emit_signal("strength_update",-item.properties.get("strength",0))
		if "defense" in item.properties: GameEvents.emit_signal("defense_update",-item.properties.get("defense",0))
		armour = null
		if(not discard): item_add(item)
	elif type == GlobalVariables.EquipmentTypes.BOOTS:
		if boots==null: return
		var item = boots
		if "strength" in item.properties: GameEvents.emit_signal("strength_update",-item.properties.get("strength",0))
		if "defense" in item.properties: GameEvents.emit_signal("defense_update",-item.properties.get("defense",0))
		boots = null
		
		# if not discarding add back
		if(not discard): item_add(item)
	GameEvents.emit_signal("unequip",type)

# add item to inventory
func item_add(object):
	if inventory.size() < max_size:
		inventory.push_back(object)
		GameEvents.emit_signal("item_add",inventory[inventory.size()-1])
	else:
		GameEvents.emit_signal("inventory_full") # inventory full so cant add
		

# discard an item
func item_remove(idx):
	GameEvents.emit_signal("item_remove",idx)
	inventory.remove(idx)

# returns added strength from equiped items
func get_bonus_strength():
	var strength = 0
	if accessory:
			strength+=accessory.properties.get("strength",0)
	if helmet:
			strength+=helmet.properties.get("strength",0)
	if armour:
			strength+=armour.properties.get("strength",0)
	if boots:
			strength+=boots.properties.get("strength",0)
	return strength

# returns added defense from equiped items
func get_bonus_defense():
	var defense = 0
	if accessory:
			defense+=accessory.properties.get("defense",0)
	if helmet:
			defense+=helmet.properties.get("defense",0)
	if armour:
			defense+=armour.properties.get("defense",0)
	if boots:
			defense+=boots.properties.get("defense",0)
	return defense

# reset data
func reset():
	inventory = []
	accessory = null
	helmet = null
	armour = null
	boots = null
