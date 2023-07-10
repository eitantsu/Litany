extends Area2D

# zone that a player can move into and change scenes, like a door

export(String, FILE, "*.tscn,*.scn") var scene_path

export(int) var my_id # my id of all zones in level
export(int) var other_id # zone to transport to id
var pos # where player should spawn
export(float) var facing # player facing direction

# on contact change scene
func _on_SceneChangeZone_body_entered(body: Node) -> void:
	if body.get_collision_layer_bit(0): # is player?
		SceneManager.scene_change(scene_path,other_id)

func _ready() -> void:
	pos = $PlayerPos.global_position

# temporarily disable self so that player doesnt accidently go back immediately
func temp_disable():
	$CollisionShape2D.disabled = true
	yield(get_tree().create_timer(2),"timeout")
	$CollisionShape2D.disabled = false
