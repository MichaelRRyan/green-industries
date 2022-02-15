extends Node2D

onready var _game_state = Utility.get_dependency("game_state", self, true)
onready var _build_tool = Utility.get_dependency("build_tool", self, true)
onready var _terrain = Utility.get_dependency("terrain", self, true)

var _command_factory : CommandFactories.CommandFactory = null


# ------------------------------------------------------------------------------
func _ready():
	if Network.is_host():
		_command_factory = CommandFactories.HostCommandFactory.new()
		print("Host commands")
	elif Network.is_client():
		_command_factory = CommandFactories.ClientCommandFactory.new()
		print("Client commands")
	else:
		_command_factory = CommandFactories.OfflineCommandFactory.new()
		print("Offline commands")


# ------------------------------------------------------------------------------
func _unhandled_input(event):
	# If the select input is pressed.
	if event.is_action_pressed("select"):
		
		# If the SELECT tool is not selected.
		if Tool.Type.SELECT != _game_state.get_selected_tool():
			
			# Gets the mouse position.
			var mouse_pos = get_global_mouse_position()
			var mouse_tile : Vector2 = _terrain.get_tile_from_global_position(mouse_pos)
			
			# If the build tool is selected.
			if Tool.Type.BUILD == _game_state.get_selected_tool():
				
				# Gets the building type, creates  and executes the build command.
				var type = _build_tool.get_building_type()
				var command = _command_factory.create_build_command(mouse_tile, type)
				command.execute()
			
			elif Tool.Type.BUY_LAND == _game_state.get_selected_tool():
				var command = _command_factory.create_buy_land_command(mouse_tile)
				command.execute()


# ------------------------------------------------------------------------------
