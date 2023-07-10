extends Node

# signals singleton, provides global access to signals

signal start_dialogue (dialogue)
signal advance_dialogue
signal end_dialogue
signal pressed_interact
signal picked_item(item)
signal hp_update (hp_change)
signal show_settings
signal show_load (menu)
signal show_save
signal show_main
signal show_inventory
signal strength_update (str_change)
signal defense_update (def_change)
signal inventory_full
signal item_add(item)
signal item_remove(idx)
signal equip(idx)
signal unequip(type)
signal is_player_detected(detected)
signal player_dead
signal change_player_pos(pos)
signal scene_ready
signal player_ready
signal hide_blur
signal show_pause
signal show_death
signal instanced_item_pick
signal boss_dead
signal camera_offset (o)
