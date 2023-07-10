extends Control

# logic for dialogue

var current_dialogue :DialogueResource
var current_line_idx :=0

export(NodePath) onready var player_texture = get_node(player_texture) as TextureRect
export(NodePath) onready var npc_texture = get_node(npc_texture) as TextureRect
export(NodePath) onready var label = get_node(label) as Label


func _ready() -> void:
	hide()
	GameEvents.connect("advance_dialogue",self,"advance_dialogue")
	GameEvents.connect("end_dialogue",self,"end_dialogue")
	GameEvents.connect("start_dialogue",self,"start_dialogue")

# display next line
func advance_dialogue():
	$AudioStreamPlayer.play()
	if current_line_idx < current_dialogue.lines.size()-1:
		current_line_idx+=1
		label.text=current_dialogue.lines[current_line_idx]
	else:
		GameEvents.emit_signal("end_dialogue") # last line, exit dialogue

# when dialogue is opened do initialization
func start_dialogue(dialogue :DialogueResource):
	current_dialogue=dialogue
	player_texture.texture=current_dialogue.player_texture
	npc_texture.texture=current_dialogue.npc_texture
	label.text=current_dialogue.lines[0]
	$VBoxContainer/MarginContainer/ReferenceRect/Panel/MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer/Skip.grab_focus()
	show()

# when dialogue ends reset
func end_dialogue():
	$AudioStreamPlayer.play()
	current_line_idx=0
	hide()

# end dialogue and close screen
func _on_Skip_pressed() -> void:
	$AudioStreamPlayer.play()
	GameEvents.emit_signal("end_dialogue")

# advance line
func _on_Next_pressed() -> void:
	$AudioStreamPlayer.play()
	GameEvents.emit_signal("advance_dialogue")
