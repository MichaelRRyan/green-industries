extends Control

const CONNECT_TEXT = ["Waiting for players...", "Connecting to server..."]


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
	
	$host/IP.text = "Private IP: " + host



func _on_HostButton_pressed():
	
	if Network.state == Network.State.HOSTING: return

	if Network.state != Network.State.OFFLINE:
		Network.close_connection()
	
	set_connect_type(true)
	Network.start_server()
	
	rpc("begin_game")
	begin_game()


func _on_JoinButton_pressed():
	if Network.state == Network.State.CONNECTING: return
	
	if Network.state != Network.State.OFFLINE:
		Network.close_server()
		
	if $join/IP.text.is_valid_ip_address():
		Network.current_players += 1
		set_connect_type(false)
		Network.connect_to_server($join/IP.text)
	else:
		$join/InvalidIP.show()


remote func begin_game():
	if Network.state != Network.State.SOLO: 
		var _val=get_tree().change_scene("res://Scenes/gameplay.tscn")


func _on_solo_pressed():
	Network.state = Network.State.SOLO
	if Network.state == Network.State.SOLO: 
		Network.solo_Player()
		
		
func set_connect_type(host):
	$Connecting.show()
	if host:
		$Connecting/Label.text = CONNECT_TEXT[0]
	else:
		$Connecting/Label.text = CONNECT_TEXT[1]
