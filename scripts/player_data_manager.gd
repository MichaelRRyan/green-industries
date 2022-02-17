extends Node

onready var local_player_data = get_node("PlayerData")

var PlayerDataScene = preload("res://scenes/player_data.tscn")
var owner_dict = {}
var ai_scene = load("res://scenes/ai.tscn")
var ais = []
var ai_data = []
var networked_players = {}
var colour_outlines = [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 ]

#-------------------------------------------------------------------------------
func _ready() -> void:
	#local_player_data._inventory.set_money(50000)
	networked_players[1] = local_player_data
	local_player_data.outline_id = colour_outlines.front()
	colour_outlines.remove(0)
	
	if not Network.is_client():
		var id = 1
		for _i in range(9):
			id += 1
			var player_data = PlayerDataScene.instance()
			add_child(player_data)
			player_data.set_name("PlayerData" + str(id))
			player_data.set_peer_id(id)
			player_data.outline_id = colour_outlines.front()
			colour_outlines.remove(0)
			ai_data.append(player_data)
			var new_ai = ai_scene.instance()
			ais.append(new_ai)
			ais.back()._set_player_data(player_data)
			networked_players[id] = ai_data.back()
			add_child(new_ai)
		
	# Connects to the player connected and disconnected signals if the host.
	if Network.state == Network.State.HOSTING:
		var _r = Network.connect("player_connected", self, "_on_Network_player_connected")
		_r = Network.connect("player_disconnected", self, "_on_Network_player_disconnected")
			
	# Renames its player data to match the host, if not the host.
	elif Network.state == Network.State.CONNECTED:
		var player_data = find_node("PlayerData")
		if player_data and get_tree().network_peer != null:
			player_data.set_name("PlayerData" + str(get_tree().get_network_unique_id()))
	



#-------------------------------------------------------------------------------
func _on_Network_player_connected(peer_id : int) -> void:
	var ai_id = ai_data.front().id
	ai_data.front().set_name("PlayerData" + str(peer_id))
	ai_data.front().set_peer_id(peer_id)
	networked_players[peer_id] = ai_data.front()
	ai_data.pop_front()
	ais.front()._set_inactive()
	var ai = ais.pop_front()
	ai.queue_free()
	for key in owner_dict:
		if owner_dict[key].id == ai_id:
			owner_dict[key].id = peer_id

#-------------------------------------------------------------------------------
func _on_Network_player_disconnected(peer_id : int) -> void:
	# Frees the data for any disconnected players.
	var disconnected_player_data = find_node("PlayerData" + str(peer_id), true, false)
	if disconnected_player_data:
		disconnected_player_data.queue_free()
	colour_outlines.append(networked_players[peer_id].outline_id)
	networked_players.erase(peer_id)


#-------------------------------------------------------------------------------
func accept(vistor) -> void:
	vistor.save_player_data_manager(self)
