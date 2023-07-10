extends Node2D

# base node for any level, once ready signal it

func _ready() -> void:
	GameEvents.emit_signal("scene_ready")
