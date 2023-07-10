extends Area2D

# an area that can damage others, and possibly move
class_name Damager

export(float) var damage
export(bool) var move := false
var direction :Vector2
var speed

export(bool) var kill_self := false # should it disappear on contact?


func _ready() -> void:
	connect("area_entered",self,"_on_Damager_area_entered")
	connect("body_entered",self,"_on_Damager_body_entered")
	if move:
		get_tree().create_timer(8).connect("timeout",self,"queue_free")

# destory self if hit something
func _on_Damager_area_entered(area: Area2D) -> void:
	if kill_self:
		if area.get_collision_layer_bit(3) and get_collision_mask_bit(3): # hit enemy
			queue_free()
		if area.get_collision_layer_bit(0) and get_collision_mask_bit(0): # hit player
			queue_free()

# destroy on wall collide
func _on_Damager_body_entered(body: Node):
	if kill_self:
		queue_free()

# move towards direction if move is true
func _process(delta: float) -> void:
	if move:
		var velocity = direction
		velocity = velocity.normalized() * speed
		position += velocity * delta
