extends Node

signal player_connected(peer_id)
signal player_disconnected(peer_id)
signal connection_succeeded
signal server_opened
signal single_player

const SERVER_ID = 1

enum State {
	OFFLINE,
	CONNECTING,
	CONNECTED,
	HOSTING,
	SOLO,
}

var state = State.OFFLINE

var network = NetworkedMultiplayerENet.new()
var port = 1909
var max_players = 10
var is_online = false # Stored as an alternative to state for quick checks.
var current_players = 0

func _ready():
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")
	network.connect("connection_failed", self, "_on_connection_failed")
	

func solo_Player():
	if state == State.SOLO:
		emit_signal("single_player")
		print("ONE PLAYER NOT A SERVER")
		var _val = get_tree().change_scene("res://scenes/gameplay/gameplay.tscn")


func start_server():
	if state == State.OFFLINE:
		network.create_server(port, max_players)
		get_tree().set_network_peer(network)
		state = State.HOSTING
		emit_signal("server_opened")
		print("Server Started")
		is_online = true


func close_connection():
	if state == State.HOSTING or state == State.CONNECTED:
		network.close_connection()
		state = State.OFFLINE
		is_online = false
	

func _peer_connected(peer_id):
	print("peer connected")
	current_players += 1
	emit_signal("player_connected", peer_id)
	print("Peer " + str(peer_id) + " Connected")
	
	if state == State.HOSTING:
		print("Hosting")
		rpc_id(peer_id, "save_terrain_data", TerrainData.noise_seed)


remote func save_terrain_data(noise_seed):
	TerrainData.noise_seed = noise_seed
	var _val = get_tree().change_scene("res://scenes/gameplay/gameplay.tscn")
	
	
func _peer_disconnected(peer_id):
	emit_signal("player_disconnected", peer_id)
	print("Peer " + str(peer_id) + " Disconnected")


func connect_to_server(ip : String):
	if state == State.OFFLINE:
		network.create_client(ip, port)
		get_tree().set_network_peer(network)
		state = State.CONNECTING


func _on_connection_succeeded():
	state = State.CONNECTED
	emit_signal("connection_succeeded")
	print("Succesfully Connected")
	is_online = true
	

func _on_connection_failed():
	state = State.OFFLINE
	print("Failed to Connect")


func is_host() -> bool:
	return state == State.HOSTING
	
	
func is_client() -> bool:
	return state == State.CONNECTED

