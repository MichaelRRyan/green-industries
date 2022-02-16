extends Node

onready var _local_player = find_node("PlayerData")
onready var networked_players = Utility.get_dependency("player_data_manager", self, true).networked_players


# ------------------------------------------------------------------------------
func _on_Tools_building_placed(building : Node2D, type : int, owner_id : int) -> void:
	networked_players[owner_id].on_building_placed(building, type)

# ------------------------------------------------------------------------------
