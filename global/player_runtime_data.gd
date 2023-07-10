extends Resource

# player data resource, provides runtime access to player through dependency injection

class_name PlayerRuntimeData

export(Dictionary) var properties

# reset all data
func reset():
	properties = {}
