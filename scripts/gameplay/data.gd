extends Node

onready var _local_player = find_node("PlayerData")
onready var networked_players = Utility.get_dependency("player_data_manager", self, true).networked_players


# ------------------------------------------------------------------------------
func _on_Tools_building_placed(building : Node2D, type : int, owner_id : int) -> void:
	if Network.state != Network.State.SOLO:
		networked_players[owner_id].on_building_placed(building, type)
	else:
		networked_players[1].on_building_placed(building, type)

# ------------------------------------------------------------------------------
