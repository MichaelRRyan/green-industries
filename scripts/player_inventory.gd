extends Node

var _owned_buildings : Array = []
var _resources = { }


func _on_BuildTool_building_placed(building : Node2D, type : int):
	_owned_buildings.append(building)
	
	# Needs to be refactored in the future.
	if type == Tile.Type.LUMBERJACK or type == Tile.Type.MINE:
		var _r = building.connect("resource_gathered", self, 
			"_on_harvester_resource_gathered")


func _on_harvester_resource_gathered(resource : ResourceType):
	if _resources.has(resource):
		_resources[resource] += 1
	else:
		_resources[resource] = 1
	
	print(resource.name + " x " + str(_resources[resource]))
