extends Node2D

signal resource_gathered(resource)


export var seconds_per_harvest : float = 5.0
export(Tile.Type) var harvest_tile_type : int = Tile.Type.FOREST

var _terrain = null
var _tile_position = Vector2.ZERO
var _owner_dict = null

# ------------------------------------------------------------------------------
func set_seconds_per_harvest(new_time : float) -> void:
	seconds_per_harvest = new_time
	$HarvestTimer.start(seconds_per_harvest)

	
# ------------------------------------------------------------------------------
func _ready() -> void:
	_terrain = Utility.get_dependency("terrain", self, true)
	_owner_dict = Utility.get_dependency("player_data_manager", self, true).owner_dict
	
	# If the terrain was found, start the harvest timer and find our tile pos.
	if _terrain and (not Network.is_online or is_network_master()):
		$HarvestTimer.start(seconds_per_harvest)
		_tile_position = _terrain.get_tile_from_global_position(global_position)


# ------------------------------------------------------------------------------
func _on_HarvestTimer_timeout() -> void:
	# Loops through all the neighbours.
	for neighbour in Utility.get_neighbours(_tile_position):
		
		# Checks if the neighbour's tile type matches the harvest tile type.
		if _terrain.get_cellv(neighbour) == harvest_tile_type:
			if _owner_dict.has(neighbour):
				
				if (Network.state == Network.State.SOLO and _owner_dict[neighbour].id == 1) \
					or _owner_dict[neighbour].id == get_tree().get_network_unique_id():
						# Tries to harvest the tile.
						var resource = _terrain.harvest_cell(neighbour)
						
						# If resources were returned, print and break from the loop.
						if resource:
							print("+1 " + resource.name)
							emit_signal("resource_gathered", resource)
							break


# ------------------------------------------------------------------------------+
