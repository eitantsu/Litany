extends Node2D

# node to handle boss room logic

export(NodePath) onready var door1 = get_node(door1) as CollisionShape2D
export(NodePath) onready var door2 = get_node(door2) as CollisionShape2D

func _ready() -> void:
	GameEvents.connect("boss_dead",self,"enable_doors")
	door1.disabled = true
	door2.disabled = true

func enable_doors():
	door1.set_deferred("disabled",false)
	door2.set_deferred("disabled",false)
