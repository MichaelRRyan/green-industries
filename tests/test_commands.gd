extends "res://addons/gut/test.gd"

const EXECUTE_METHOD_NAME = "execute"
const CREATE_BUILD_COMMAND_METHOD_NAME = "create_build_command"
const CREATE_BUY_LAND_COMMAND_METHOD_NAME = "create_buy_land_command"

const TERRAIN_NAME : String = "Terrain"
const PLAYER_DATA_MANAGER_NAME : String = "PlayerDataManager"
const USER_INPUT_NAME : String = "UserInput"

var GameplayScene = preload("res://scenes/gameplay/gameplay.tscn")

const TEST_TILE = Vector2(0, 0)


func before_all() -> void:
	yield(yield_for(0.1), YIELD)


# ------------------------------------------------------------------------------
func test_abstract_command_exists() -> void:
	# Asserts the abstract command exists.
	assert_not_null(Commands.AbstractCommand)
	
	# Checks the command has the execute method.
	var command = Commands.AbstractCommand.new()
	assert_has_method(command, EXECUTE_METHOD_NAME)


# ------------------------------------------------------------------------------
func test_command_factory_follows_the_pattern() -> void:
	# Asserts the command factories exist.
	assert_not_null(CommandFactories.CommandFactory)
	assert_not_null(CommandFactories.OfflineCommandFactory)
	
	# Creates a variable of the 'abstract' command factory type.
	var factory : CommandFactories.CommandFactory
	
	#  Assigns the factory variable an instance of the 'abstract' command  
	#	factory (This is solely for testing purposes).
	factory = CommandFactories.CommandFactory.new()
	
	# Asserts that the 'abstract' command factory has the necessary methods.
	assert_has_method(factory, CREATE_BUILD_COMMAND_METHOD_NAME)
	assert_has_method(factory, CREATE_BUY_LAND_COMMAND_METHOD_NAME)
	
	# Assigns the factory variable an instance of the offline command factory
	#	asserts that it extends the 'abstract' command factory.
	factory = CommandFactories.OfflineCommandFactory.new()
	assert_is(factory, CommandFactories.CommandFactory)


# ------------------------------------------------------------------------------
func test_offline_command_factory_can_create_commands() -> void:
	# Creates a variable of the 'abstract' command factory type.
	var factory : CommandFactories.CommandFactory
	
	# Assigns the factory variable an instance of the offline command factory.
	factory = CommandFactories.OfflineCommandFactory.new()
	
	# Uses the factory to create a build command (the arguments don't matter).
	var command = factory.create_build_command(Vector2(), 0, 0)
	
	# Asserts the command is the correct type and extends the build command.
	assert_is(command, Commands.OfflineBuildCommand)
	assert_is(command, Commands.BuildCommand)
	
	# Uses the factory to create a buy land command (the arguments don't matter).
	command = factory.create_buy_land_command(Vector2(), 0)
	
	# Asserts the command is the correct type and extends the build command.
	assert_is(command, Commands.OfflineBuyLandCommand)
	assert_is(command, Commands.BuyLandCommand)


# ------------------------------------------------------------------------------
func test_offline_build_command_places_building() -> void:
	# Checks the gameplay scene isn't null and then adds it as a child.
	assert_not_null(GameplayScene)
	var gameplay = GameplayScene.instance()
	add_child(gameplay)
	
	# Finds a child node with the terrain name and ensures it's not null.
	var terrain = find_node(TERRAIN_NAME, true, false)
	assert_not_null(terrain)
	
	# Creates a variable of the 'abstract' command factory type.
	var factory : CommandFactories.CommandFactory
	
	# Assigns the factory variable an instance of the offline command factory.
	factory = CommandFactories.OfflineCommandFactory.new()
	
	# Uses the factory to create a build command.
	var command = factory.create_build_command(Vector2(), Tile.Type.LUMBERJACK, 1)
	
	assert_not_null(command) # Asserts a command was returned.

	# Checks the command does not place a building on an occupied tile.
	terrain.set_cellv(TEST_TILE, Tile.Type.FOREST)
	command.execute()
	assert_eq(terrain.get_cellv(TEST_TILE), Tile.Type.FOREST)
	
	# Makes the tile empty and ensures the build command places a building on it.
	terrain.set_cellv(TEST_TILE, Tile.Type.GRASS)
	command.execute()
	assert_eq(terrain.get_cellv(TEST_TILE), Tile.Type.LUMBERJACK)
	
	gameplay.free()
	

# ------------------------------------------------------------------------------
func test_offline_buy_land_command_places_building() -> void:
	# Checks the gameplay scene isn't null and then adds it as a child.
	assert_not_null(GameplayScene)
	var gameplay = GameplayScene.instance()
	add_child(gameplay)
	
	# Finds a child node with the player data name and ensures it's not null.
	var player_data_manager = find_node(PLAYER_DATA_MANAGER_NAME, true, false)
	assert_not_null(player_data_manager)
	
	# Gets a the player data's inventory and ensures it's not null.
	var inventory = player_data_manager.local_player_data._inventory
	assert_not_null(inventory)
	
	# Creates a variable of the 'abstract' command factory type.
	var factory : CommandFactories.CommandFactory
	
	# Assigns the factory variable an instance of the offline command factory.
	factory = CommandFactories.OfflineCommandFactory.new()
	
	# Uses the factory to create a buy land command.
	var command = factory.create_buy_land_command(TEST_TILE, 1)
	
	assert_not_null(command) # Asserts a command was returned.

	# Checks the command does not buy a tile if we have no money.
	inventory.set_money(0)
	command.execute()
	assert_does_not_have(player_data_manager.owner_dict, TEST_TILE)
	
	# Adds money and checks the command will buy the tile.
	inventory.set_money(50000)
	command.execute()
	assert_has(player_data_manager.owner_dict, TEST_TILE)
	
	gameplay.free()


# ------------------------------------------------------------------------------
func test_factory_output_depends_on_network_state() -> void:
	# Checks the gameplay scene isn't null
	assert_not_null(GameplayScene)
	
	# Sets the network state to SOLO.
	Network.state = Network.State.SOLO
	
	var gameplay = GameplayScene.instance()
	add_child(gameplay)
	yield(yield_for(0.2), YIELD)
	var factory = find_node(USER_INPUT_NAME, true, false)._command_factory
	assert_not_null(factory)
	
	# Ensures the factory and its commands are the right type.
	
	assert_is(factory, CommandFactories.OfflineCommandFactory)
	var build_cmd = factory.create_build_command(Vector2(), 0, 0)
	var buy_land_cmd = factory.create_buy_land_command(Vector2(), 0)
	assert_is(build_cmd, Commands.OfflineBuildCommand)
	assert_is(buy_land_cmd, Commands.OfflineBuyLandCommand)
	
	# Frees the scene and starts again.
	gameplay.free()
	
	# Sets the network state to HOSTING.
	Network.state = Network.State.HOSTING
	
	gameplay = GameplayScene.instance()
	add_child(gameplay)
	factory = find_node("CommandTool", true, false).command_factory
	assert_not_null(factory)
	
	# Ensures the factory and its commands are the right type.
	assert_is(factory, CommandFactories.HostCommandFactory)
	build_cmd = factory.create_build_command(Vector2(), 0, 0)
	buy_land_cmd = factory.create_buy_land_command(Vector2(), 0)
	assert_is(build_cmd, Commands.HostBuildCommand)
	assert_is(buy_land_cmd, Commands.HostBuyLandCommand)
	
	# Frees the scene and starts again.
	gameplay.free()
	
	# Sets the network state to CONNECTED.
	Network.state = Network.State.CONNECTED
	
	gameplay = GameplayScene.instance()
	add_child(gameplay)
	factory = find_node("CommandTool", true, false).command_factory
	assert_not_null(factory)
	
	# Ensures the factory and its commands are the right type.
	assert_is(factory, CommandFactories.ClientCommandFactory)
	build_cmd = factory.create_build_command(Vector2(), 0, 0)
	buy_land_cmd = factory.create_buy_land_command(Vector2(), 0)
	assert_is(build_cmd, Commands.ClientBuildCommand)
	assert_is(buy_land_cmd, Commands.ClientBuyLandCommand)
	
	gameplay.free()
	
	# Resets to avoid interfering with other tests.
	Network.state = Network.State.OFFLINE


# ------------------------------------------------------------------------------
