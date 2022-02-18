extends Node

var command_factory : CommandFactories.CommandFactory = null

func _ready():
	if Network.is_host():
		command_factory = CommandFactories.HostCommandFactory.new()
		print("Host commands")
	elif Network.is_client():
		command_factory = CommandFactories.ClientCommandFactory.new()
		print("Client commands")
	else:
		command_factory = CommandFactories.OfflineCommandFactory.new()
		print("Offline commands")

