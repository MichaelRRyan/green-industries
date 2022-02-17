class_name CommandFactories # Like a namespace, contains all the command factories.


# ------------------------------------------------------------------------------
# The abstract command factory.
class CommandFactory:
	
	# --------------------------------------------------------------------------
	# Pure virtual, throws an error if called.
	func create_build_command(_tile_pos : Vector2, _building_type : int, _owner_id : int = 1) \
		-> Commands.BuildCommand:
			
		assert(false)
		return Commands.BuildCommand.new()
	
	# --------------------------------------------------------------------------
	# Pure virtual, throws an error if called.
	func create_buy_land_command(_tile_pos : Vector2, _owner_id : int = 1) \
		-> Commands.BuyLandCommand:
			
		assert(false)
		return Commands.BuyLandCommand.new()
		
	func create_bulldoze_command(_tile_pos : Vector2, _owner_id : int = 1) \
		-> Commands.BullDozeCommand:
		assert(false)
		return Commands.BullDozeCommand.new()


# ------------------------------------------------------------------------------
# Used for offline games.
class OfflineCommandFactory:
	extends CommandFactory
	
	# --------------------------------------------------------------------------
	func create_build_command(tile_pos : Vector2, building_type : int, owner_id : int = 1) \
		-> Commands.BuildCommand:
			
		var command = Commands.OfflineBuildCommand.new()
		command.setup(tile_pos, building_type, owner_id)
		return command
	
	# --------------------------------------------------------------------------
	func create_buy_land_command(tile_pos : Vector2, owner_id : int = 1) \
		-> Commands.BuyLandCommand:
		
		var command = Commands.OfflineBuyLandCommand.new()
		command.setup(tile_pos, owner_id)
		return command
		
	func create_bulldoze_command(_tile_pos : Vector2, _owner_id : int = 1) \
		-> Commands.BullDozeCommand:
		var command = Commands.OfflineBullDozeCommand.new()
		command.setup(_tile_pos, _owner_id)
		return command


# ------------------------------------------------------------------------------
# Used for hosted games.
class HostCommandFactory:
	extends CommandFactory
	
	# --------------------------------------------------------------------------
	func create_build_command(tile_pos : Vector2, building_type : int, owner_id : int = 1) \
		-> Commands.BuildCommand:
			
		var command = Commands.HostBuildCommand.new()
		command.setup(tile_pos, building_type, owner_id)
		return command
	
	# --------------------------------------------------------------------------
	func create_buy_land_command(tile_pos : Vector2, owner_id : int = 1) \
		-> Commands.BuyLandCommand:
		
		var command = Commands.HostBuyLandCommand.new()
		command.setup(tile_pos, owner_id)
		return command
		
	func create_bulldoze_command(_tile_pos : Vector2, _owner_id : int = 1) \
		-> Commands.BullDozeCommand:
		var command = Commands.HostBullDozeCommand.new()
		command.setup(_tile_pos, _owner_id)
		return command


# ------------------------------------------------------------------------------
# Used for multiplayer games as the client.
class ClientCommandFactory:
	extends CommandFactory
	
	# --------------------------------------------------------------------------
	func create_build_command(tile_pos : Vector2, building_type : int, _unused_id : int = -1) \
		-> Commands.BuildCommand:
			
		var command = Commands.ClientBuildCommand.new()
		command.setup(tile_pos, building_type)
		return command
	
	# --------------------------------------------------------------------------
	func create_buy_land_command(tile_pos : Vector2, _unused_id : int = -1) \
		-> Commands.BuyLandCommand:
		
		var command = Commands.ClientBuyLandCommand.new()
		command.setup(tile_pos)
		return command

	func create_bulldoze_command(_tile_pos : Vector2, _owner_id : int = 1) \
		-> Commands.BullDozeCommand:
		var command = Commands.ClientBullDozeComand.new()
		command.setup(_tile_pos, _owner_id)
		return command
# ------------------------------------------------------------------------------
