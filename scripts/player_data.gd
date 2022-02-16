extends Node

var _owned_buildings : Array = []
onready var _inventory : Inventory = get_node("Inventory")
var outline_id
var id = 0

# ------------------------------------------------------------------------------
func set_peer_id(peer_id : int) -> void:
	_inventory.set_peer_id(peer_id)
	id = peer_id
	
	
# ------------------------------------------------------------------------------
func on_building_placed(building : Node2D, type : int) -> void:
	_owned_buildings.append(building)
	
	# Needs to be refactored in the future.
	if type == Tile.Type.LUMBERJACK or type == Tile.Type.MINE:
		var _r = building.connect("resource_gathered", self, 
			"_on_harvester_resource_gathered")

	
# ------------------------------------------------------------------------------
func _on_harvester_resource_gathered(resource : ResourceType) -> void:
	_inventory.add_resources(resource, 1)

	
# ------------------------------------------------------------------------------
