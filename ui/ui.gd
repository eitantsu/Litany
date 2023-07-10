extends Control

# ui stats logic

export(NodePath) onready var hp_bar = get_node(hp_bar) as TextureProgress
export(NodePath) onready var strength_l = get_node(strength_l) as Label
export(NodePath) onready var defense_l = get_node(defense_l) as Label
export(Resource) var player_runtime_data = player_runtime_data as PlayerRuntimeData
var strength
var defense

func _ready() -> void:
	yield(GameEvents,"player_ready")
	GameEvents.connect("hp_update",self,"hp_update")
	GameEvents.connect("defense_update",self,"defense_update")
	GameEvents.connect("strength_update",self,"strength_update")
	hp_bar.value = player_runtime_data.properties["hp"]
	hp_bar.value = clamp(hp_bar.value,0,100)
	strength = player_runtime_data.properties["strength"]
	defense = player_runtime_data.properties["defense"]
	strength_l.text = "Strength: " + str(strength)
	defense_l.text = "Defense: " + str(defense)

# update hp bar
func hp_update(hp_change):
	if hp_change<0:
		hp_change+=defense
		if hp_change>=0:
			hp_change = -1
	hp_bar.value = hp_bar.value + hp_change
	hp_bar.value = clamp(hp_bar.value,0,100)
	
# update strength text
func strength_update(strength_change):
	strength_l.text = "Strength: " + str(strength_change + strength)
	strength = strength + strength_change

# update defense text
func defense_update(defense_change):
	defense_l.text = "Defense: " + str(defense_change + defense)
	defense = defense + defense_change

# on load update strength,defense,hp
func load_self(slot):
	strength_l.text = "Strength: " + str(slot.player_data.properties["strength"] )
	defense_l.text = "Defense: " + str(slot.player_data.properties["defense"] )
	hp_bar.value = float(slot.player_data.properties["hp"])

func save_self(slot):
	pass
