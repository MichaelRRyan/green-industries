extends Control

const CONNECT_TEXT = ["Waiting for players...", "Connecting to server..."]

onready var _ip_label = find_node("IP")
onready var _ip_input = find_node("IPInput")
onready var _invalid_ip = find_node("InvalidIP")
onready var _player_list = find_node("PlayerListBackground")
onready var _host_button = find_node("HostButton")

func _ready():
	var host : String = "Unknown"
	
	if OS.has_feature("Windows"):
		if OS.has_environment("COMPUTERNAME"):
			host =  IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),1)
	elif OS.has_feature("X11"):
		if OS.has_environment("HOSTNAME"):
			host =  IP.resolve_hostname(str(OS.get_environment("HOSTNAME")),1)
	elif OS.has_feature("OSX"):
		if OS.has_environment("HOSTNAME"):
			host =  IP.resolve_hostname(str(OS.get_environment("HOSTNAME")),1)
	
	_ip_label.text = "IP: " + host



func _on_HostButton_pressed():
	
	if Network.state != Network.State.OFFLINE:
		Network.close_connection()
		_host_button.text = "Host"
		_ip_label.hide()
		randomize()
		TerrainData.noise_seed = randi()
	else:
		Network.start_server()
		_host_button.text = "Close Server"
		_ip_label.show()
		#set_connect_type(true)
		#begin_game()


func _on_JoinButton_pressed():
	if Network.state == Network.State.CONNECTING: return
	
	if Network.state != Network.State.OFFLINE:
		Network.close_connection()
		
	if _ip_input.text.is_valid_ip_address():
		Network.current_players += 1
		set_connect_type(false)
		Network.connect_to_server(_ip_input.text)
	elif _ip_input.text == "":
		Network.current_players += 1
		set_connect_type(false)
		Network.connect_to_server("127.0.0.1")
	else:
		_invalid_ip.show()


remote func begin_game():
	if Network.state != Network.State.SOLO: 
		var _val=get_tree().change_scene("res://scenes/gameplay/gameplay.tscn")


func _on_StartButton_pressed():
	if Network.state == Network.State.OFFLINE:
		Network.state == Network.State.SOLO
		randomize()
		TerrainData.noise_seed = randi()	
		
	var _r = get_tree().change_scene("res://scenes/gameplay/gameplay.tscn")
		
		
func set_connect_type(host):
	$Connecting.show()
	if host:
		$Connecting/Label.text = CONNECT_TEXT[0]
	else:
		$Connecting/Label.text = CONNECT_TEXT[1]


func _on_TabContainer_tab_changed(tab):
	_player_list.visible = tab == 0
