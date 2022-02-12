extends Node

onready var local_player_data = get_node("PlayerData")

var PlayerDataScene = preload("res://scenes/player_data.tscn")
var owner_dict = {}
var networked_players = {}
var colour_outlines = [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 ]

#-------------------------------------------------------------------------------
func _ready() -> void:
	local_player_data._inventory.set_money(30000)
	# Connects to the player connected and disconnected signals if the host.
	if Network.state == Network.State.HOSTING:
		var _r = Network.connect("player_connected", self, "_on_Network_player_connected")
		_r = Network.connect("player_disconnected", self, "_on_Network_player_disconnected")
	
	# Renames its player data to match the host, if not the host.
	elif Network.state == Network.State.CONNECTED:
		var player_data = find_node("PlayerData")
		if player_data:
			player_data.set_name("PlayerData" + str(get_tree().get_network_unique_id()))
	
	networked_players[1] = local_player_data
	local_player_data.outline_id = colour_outlines.front()
	colour_outlines.remove(0)


#-------------------------------------------------------------------------------
func _on_Network_player_connected(peer_id : int) -> void:
	# Creates, names, and adds a new player data child with the correct peer id.
	var player_data = PlayerDataScene.instance()
	add_child(player_data)
	player_data.set_name("PlayerData" + str(peer_id))
	player_data.set_peer_id(peer_id)
	player_data.outline_id = colour_outlines.front()
	colour_outlines.remove(0)
	networked_players[peer_id] = player_data

#-------------------------------------------------------------------------------
func _on_Network_player_disconnected(peer_id : int) -> void:
	# Frees the data for any disconnected players.
	var disconnected_player_data = find_node("PlayerData" + str(peer_id), true, false)
	if disconnected_player_data:
		disconnected_player_data.queue_free()
	colour_outlines.append(networked_players[peer_id].outline_id)
	networked_players.erase(peer_id)


#-------------------------------------------------------------------------------
