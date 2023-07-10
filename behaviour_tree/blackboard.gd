tool
extends Node

# data structure of behavior tree, acts as dictionary

class_name Blackboard

var blackboard :Dictionary

func set(key,value):
	blackboard[key]=value

func get(key):
	return blackboard[key]

func exists(key):
	return blackboard.has(key)
