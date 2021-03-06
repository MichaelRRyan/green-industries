class_name States


# ------------------------------------------------------------------------------
#basic standby wait state when no decision needed
class IdleState:
	extends State
	
	# --------------------------------------------------------------------------
	func update(_delta : float) -> void:
		# If the AI owns 2 or more tiles but has no resources.
		if (not _ai.no_resources_nearby and
			_ai.controlled_tiles.size() >= 2 and
			!_ai.controlled_tiles_dict.has(Tile.Type.FOREST) and
			!_ai.controlled_tiles_dict.has(Tile.Type.STONE)):
			state_machine.transition_to(BuyResourceTileState)
			
		elif !_ai.controlled_tiles_dict.has(Tile.Type.GRASS):
			state_machine.transition_to(BuyEmptyLandState)
			
		elif (_ai.ai_data._inventory.get_quantity(_ai._resource_manager.get_resource_type_by_name("minerals")) > 0 and\
				!_ai.ai_data.owned_buildings.has(Tile.Type.MINERALS_FACTORY)) or\
				(_ai.ai_data._inventory.get_quantity(_ai._resource_manager.get_resource_type_by_name("wood")) > 0 and\
				!_ai.ai_data.owned_buildings.has(Tile.Type.WOOD_FACTORY)):
					state_machine.transition_to(PlaceFactoryState)
					
		elif !_ai.controlled_tiles_dict.has(Tile.Type.POWER_PLANT) or (_ai.controlled_tiles_dict.has(Tile.Type.POWER_PLANT)\
				and !_ai.ai_data.owned_buildings[Tile.Type.POWER_PLANT].front().is_powered()):
					state_machine.transition_to(NoPowerState)
					
		elif (_ai.ai_data._inventory.get_quantity(_ai._resource_manager.get_resource_type_by_name("minerals")) > 0 and\
				!_ai.ai_data.owned_buildings.has(Tile.Type.MINERALS_REFINERY)) or\
				(_ai.ai_data._inventory.get_quantity(_ai._resource_manager.get_resource_type_by_name("wood")) and\
				!_ai.ai_data.owned_buildings.has(Tile.Type.WOOD_REFINERY)):
					state_machine.transition_to(PlaceRefinaryState)
					
		elif (_ai.ai_data._inventory.get_quantity(_ai._resource_manager.get_resource_type_by_name("lumber")) > 0 and\
				!_ai.ai_data.owned_buildings.has(Tile.Type.LUMBER_FACTORY)) or\
				(_ai.ai_data._inventory.get_quantity(_ai._resource_manager.get_resource_type_by_name("metal")) and\
				!_ai.ai_data.owned_buildings.has(Tile.Type.METAL_FACTORY)):
					state_machine.transition_to(PlaceFactoryState)


# ------------------------------------------------------------------------------
#state to start the AI off
class StartState:
	extends State
	
	
	# --------------------------------------------------------------------------
	func update(_delta : float) -> void:
		var _buy_tile : Vector2 = Vector2(randi() % _ai.TILE_MAP_SIZE, randi() % _ai.TILE_MAP_SIZE)
		var still_looking = true
		while _ai._player_data_manager.owner_dict.has(_buy_tile) or still_looking:
			_buy_tile = Vector2(randi() % _ai.TILE_MAP_SIZE, randi() % _ai.TILE_MAP_SIZE)
			var neighbours = Utility.get_neighbours(_buy_tile)
			var contains_trees = false
			var contains_minerals = false
			for neighbour in neighbours:
				if _ai._terrain.get_cellv(neighbour) == Tile.Type.FOREST:
					contains_trees = true
				elif _ai._terrain.get_cellv(neighbour) == Tile.Type.STONE:
					contains_minerals = true
			if _ai._terrain.get_cellv(_buy_tile) == Tile.Type.GRASS and\
				(contains_trees or contains_minerals):
					still_looking = false
		var command = _ai._command_factory.create_buy_land_command(_buy_tile, _ai.ai_data.id)
		command.execute()
		_ai.add_to_controlled(_buy_tile)
		_ai._place_building_timer.start()
		state_machine.transition_to(IdleState)


# ------------------------------------------------------------------------------
class BuyResourceTileState:
	extends State
	
	
	# --------------------------------------------------------------------------
	func _find_unowned_tile_around(tile_pos : Vector2, tile_type : int) -> Vector2:
		var neighbours = Utility.get_neighbours(tile_pos)
		while not neighbours.empty():
			var neighbour = neighbours.pop_at(randi() % neighbours.size())
			if not _ai.controlled_tiles.has(neighbour):
				if tile_type == _ai._terrain.get_cellv(neighbour):
					return neighbour
		
		return Vector2(-1, -1)
	
	
	# --------------------------------------------------------------------------
	func update(_delta : float) -> void:
		# Search for a resource tile.
		#var checked = []
		#var origin = _ai.controlled_tiles.front() # First tile bought.
		#var neighbours = Utility.get_neighbours(origin)
		
		if _ai.controlled_tiles_dict.has(Tile.Type.LUMBERJACK):
			for pos in _ai.controlled_tiles_dict[Tile.Type.LUMBERJACK]:
				var tile = _find_unowned_tile_around(pos, Tile.Type.FOREST)
				if tile.x != -1: 
					var command = _ai._command_factory.create_buy_land_command(tile, _ai.ai_data.id)
					command.execute()
					_ai.add_to_controlled(tile)
					state_machine.transition_to(IdleState)
					return
		
		if _ai.controlled_tiles_dict.has(Tile.Type.MINE):
			for pos in _ai.controlled_tiles_dict[Tile.Type.MINE]:
				var tile = _find_unowned_tile_around(pos, Tile.Type.STONE)
				if tile.x != -1: 
					var command = _ai._command_factory.create_buy_land_command(tile, _ai.ai_data.id)
					command.execute()
					_ai.add_to_controlled(tile)
					state_machine.transition_to(IdleState)
					return
		
		_ai.no_resources_nearby = true
		state_machine.transition_to(IdleState)
		
#		while not neighbours.empty():
#			var neighbour = neighbours.pop_at(randi() % neighbours.size())
#			if not _ai.controlled_tiles.has(neighbour):
#				pass
	

# ------------------------------------------------------------------------------
#state to buy land when all land is used up or ai has no land
class BuyLandState:
	extends State
	
	
	# --------------------------------------------------------------------------
	func update(_delta : float) -> void:
		var neighbours = Utility.get_neighbours(_ai.controlled_tiles.front())
		var _buy_tile
		var _resource_tile_found = false
		for neighbour in neighbours:
			if _ai._terrain.get_cellv(neighbour) == Tile.Type.FOREST or\
				_ai._terrain.get_cellv(neighbour) == Tile.Type.STONE:
					_buy_tile = neighbour
					_resource_tile_found = true
					break
			
		if _buy_tile != null:
			var command = _ai._command_factory.create_buy_land_command(_buy_tile, _ai.ai_data.id)
			command.execute()
			_ai.add_to_controlled(_buy_tile)
		state_machine.transition_to(IdleState)


# ------------------------------------------------------------------------------
class BuyEmptyLandState:
	extends State
	
	
	# --------------------------------------------------------------------------
	func update(_delta : float) -> void:
		var neighbours = Utility.get_neighbours(_ai.controlled_tiles.front())
		var _buy_tile
		for neighbour in neighbours:
			if _ai._terrain.get_cellv(neighbour) == Tile.Type.GRASS:
					_buy_tile = neighbour
					break
			
		if _buy_tile != null:
			var command = _ai._command_factory.create_buy_land_command(_buy_tile, _ai.ai_data.id)
			command.execute()
			_ai.add_to_controlled(_buy_tile)
		state_machine.transition_to(IdleState)


# ------------------------------------------------------------------------------
#state to place harvester when no resources are had
class PlaceHarvesterState:
	extends State
	
	
	# --------------------------------------------------------------------------
	func update(_delta : float) -> void:
		var neighbours = Utility.get_neighbours(_ai.controlled_tiles.front())
		var contains_trees = false
		var contains_minerals = false
		for neighbour in neighbours:
			if _ai._terrain.get_cellv(neighbour) == Tile.Type.FOREST:
				contains_trees = true
			elif _ai._terrain.get_cellv(neighbour) == Tile.Type.STONE:
				contains_minerals = true
		var build_type = null
		if contains_trees:
			build_type = Tile.Type.LUMBERJACK
		elif contains_minerals:
			build_type = Tile.Type.MINE
		var _buy_tile : Vector2 = Vector2(randi() % _ai.TILE_MAP_SIZE, randi() % _ai.TILE_MAP_SIZE)
		for neighbour in neighbours:
			if _ai._terrain.get_cellv(neighbour) == Tile.Type.FOREST and build_type == Tile.Type.LUMBERJACK:
				_buy_tile = neighbour
				break
			elif _ai._terrain.get_cellv(neighbour) == Tile.Type.STONE and build_type == Tile.Type.MINE:
				_buy_tile = neighbour
				break
		if build_type != null:
			var command = _ai._command_factory.\
				create_build_command(_ai.controlled_tiles.front(), build_type, _ai.ai_data.id)
			
			command.execute()
			_ai.change_type(_ai.controlled_tiles.front(), build_type)
			state_machine.transition_to(IdleState)
			_ai._timer.start()


# ------------------------------------------------------------------------------
#state to power a power plant when its out of fuel
class NoPowerState:
	extends State
	

	# --------------------------------------------------------------------------
	func _place_power_plant_by_building(tile_type : int) -> void:
		var tile_pos = _ai._terrain.get_tile_from_global_position(\
			_ai.ai_data.owned_buildings[tile_type].front().position)
		var neighbours = Utility.get_neighbours(tile_pos)
		
		while not neighbours.empty():
			var neighbour = neighbours.pop_at(randi() % neighbours.size())
			if _ai._terrain.is_tile_empty(neighbour):
				var command = _ai._command_factory.\
					create_build_command(neighbour, Tile.Type.POWER_PLANT, _ai.ai_data.id)
				command.execute()
				_ai.change_type(neighbour, Tile.Type.POWER_PLANT)
				break
	
	
	# --------------------------------------------------------------------------
	func update(_delta : float) -> void:
		if _ai.controlled_tiles_dict.has(Tile.Type.POWER_PLANT):
			_ai.ai_data.owned_buildings[Tile.Type.POWER_PLANT].front().increase_fuel(5)
			
		elif _ai.ai_data.owned_buildings.has(Tile.Type.WOOD_REFINERY):
			_place_power_plant_by_building(Tile.Type.WOOD_REFINERY)
			
		elif _ai.ai_data.owned_buildings.has(Tile.Type.MINERALS_REFINERY):
			_place_power_plant_by_building(Tile.Type.MINERALS_REFINERY)
			
		elif _ai.ai_data.owned_buildings.has(Tile.Type.WOOD_FACTORY):
			_place_power_plant_by_building(Tile.Type.WOOD_FACTORY)
			
		elif _ai.ai_data.owned_buildings.has(Tile.Type.MINERALS_FACTORY):
			_place_power_plant_by_building(Tile.Type.MINERALS_FACTORY)
			
		elif _ai.ai_data.owned_buildings.has(Tile.Type.METAL_FACTORY):
			_place_power_plant_by_building(Tile.Type.METAL_FACTORY)
			
		elif _ai.ai_data.owned_buildings.has(Tile.Type.LUMBER_FACTORY):
			_place_power_plant_by_building(Tile.Type.LUMBER_FACTORY)
		
		state_machine.transition_to(IdleState)


# ------------------------------------------------------------------------------
#state to find a place nearby and to place specific refinary
class PlaceRefinaryState:
	extends State
	
	var resource_manager = Utility.get_dependency("resource_manager", self, true)
	
	
	# --------------------------------------------------------------------------
	func update(_delta : float) -> void:
		if _ai.controlled_tiles_dict.has(Tile.Type.GRASS):
			var _tile_pos = _ai.controlled_tiles_dict[Tile.Type.GRASS].front()
			
			if _ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("wood")) > 0 \
				and !_ai.controlled_tiles_dict.has(Tile.Type.WOOD_REFINERY):
					var command = _ai._command_factory.\
					create_build_command(_tile_pos, Tile.Type.WOOD_REFINERY, _ai.ai_data.id)
					command.execute()
					_ai.change_type(_tile_pos, Tile.Type.WOOD_REFINERY)
			elif _ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("minerals")) > 0 \
				and !_ai.controlled_tiles_dict.has(Tile.Type.MINERALS_REFINERY):
					var command = _ai._command_factory.\
					create_build_command(_tile_pos, Tile.Type.MINERALS_REFINERY, _ai.ai_data.id)
					command.execute()
					_ai.change_type(_tile_pos, Tile.Type.MINERALS_REFINERY)
			
		state_machine.transition_to(IdleState)


# ------------------------------------------------------------------------------
#state to find a place nearby and to place specific refinary
class PlaceFactoryState:
	extends State
	
	var resource_manager = Utility.get_dependency("resource_manager", self, true)
	
	
	# --------------------------------------------------------------------------
	func update(_delta : float) -> void:
		if _ai.controlled_tiles_dict.has(Tile.Type.GRASS):
			var _tile_pos = _ai.controlled_tiles_dict[Tile.Type.GRASS].front()
			
			if _ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("wood")) > 0 \
				and !_ai.controlled_tiles_dict.has(Tile.Type.WOOD_FACTORY):
					var command = _ai._command_factory.\
					create_build_command(_tile_pos, Tile.Type.WOOD_FACTORY, _ai.ai_data.id)
					command.execute()
					_ai.change_type(_tile_pos, Tile.Type.WOOD_FACTORY)
				
			elif _ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("minerals")) > 0 \
				and !_ai.controlled_tiles_dict.has(Tile.Type.MINERALS_FACTORY):
					var command = _ai._command_factory.\
					create_build_command(_tile_pos, Tile.Type.MINERALS_FACTORY, _ai.ai_data.id)
					command.execute()
					_ai.change_type(_tile_pos, Tile.Type.MINERALS_FACTORY)
				
			elif _ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("lumber")) > 0 \
				and !_ai.controlled_tiles_dict.has(Tile.Type.LUMBER_FACTORY):
					var command = _ai._command_factory.\
					create_build_command(_tile_pos, Tile.Type.LUMBER_FACTORY, _ai.ai_data.id)
					command.execute()
					_ai.change_type(_tile_pos, Tile.Type.LUMBER_FACTORY)
				
			elif _ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("metal")) > 0 \
				and !_ai.controlled_tiles_dict.has(Tile.Type.METAL_FACTORY):
					var command = _ai._command_factory.\
					create_build_command(_tile_pos, Tile.Type.METAL_FACTORY, _ai.ai_data.id)
					command.execute()
					_ai.change_type(_tile_pos, Tile.Type.METAL_FACTORY)
			
			
		state_machine.transition_to(IdleState)


# ------------------------------------------------------------------------------
#state to give resources to refinary to get the better resource
class GiveResourceToRefinaryState:
	extends State
	
	var resource_manager = Utility.get_dependency("resource_manager", self, true)
	
	
	# --------------------------------------------------------------------------
	func update(_delta : float) -> void:
		if _ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("wood")) > 0 \
			and _ai.controlled_tiles_dict.has(Tile.Type.WOOD_REFINERY):
				_ai.controlled_tiles_dict.has(Tile.Type.WOOD_REFINERY)._input_ingredients()
		if _ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("minerals")) > 0 \
			and _ai.controlled_tiles_dict.has(Tile.Type.MINERALS_REFINERY):
				_ai.controlled_tiles_dict.has(Tile.Type.MINERALS_REFINERY)._input_ingredients()
			
		state_machine.transition_to(IdleState)


# ------------------------------------------------------------------------------
class BuyResourceState:
	extends State
	
	var resource_manager = Utility.get_dependency("resource_manager", self, true)
	var amount = 5
	const max_amount = 100
	
	
	# --------------------------------------------------------------------------
	func update(_delta : float) -> void:
		
		#if it doesnt have a certain thing but the resources for it ^^ 
		if _ai.ai_data.owned_buildings.has(Tile.Type.WOOD_FACTORY) == false: 
			amount = 5 
			var buy_command = _ai._command_factory.\
				create_buy_command(resource_manager.get_resource_type_by_name("wood"),amount,_ai.ai_data.id)
			buy_command.execute()		
		elif _ai.ai_data.owned_buildings.has(Tile.Type.WOOD_FACTORY) == true and \
			_ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("wood"))<=max_amount:
				amount = 1
				var buy_command = _ai._command_factory.\
					create_buy_command(resource_manager.get_resource_type_by_name("wood"),amount,_ai.ai_data.id)
				buy_command.execute()
	
			#---------------------------------------------------------------------------------------
		if _ai.ai_data.owned_buildings.has(Tile.Type.LUMBER_FACTORY) == false: 
			amount = 5 
			var buy_command = _ai._command_factory.\
				create_buy_command(resource_manager.get_resource_type_by_name("lumber"),amount,_ai.ai_data.id)
			buy_command.execute()		
		if _ai.ai_data.owned_buildings.has(Tile.Type.LUMBER_FACTORY) == true and \
			 _ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("lumber"))<=max_amount:
				amount = 1
				var buy_command = _ai._command_factory.\
					create_buy_command(resource_manager.get_resource_type_by_name("lumber"),amount,_ai.ai_data.id)
				buy_command.execute() 
		#---------------------------------------------------------------------------------------
		if _ai.ai_data.owned_buildings.has(Tile.Type.METAL_FACTORY) == false: 
			amount = 5 
			var buy_command = _ai._command_factory.\
				create_buy_command(resource_manager.get_resource_type_by_name("metal"),amount,_ai.ai_data.id)
			buy_command.execute()		
		if _ai.ai_data.owned_buildings.has(Tile.Type.METAL_FACTORY) == true and \
			 _ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("metal"))<=max_amount:
				amount = 1
				var buy_command = _ai._command_factory.\
					create_buy_command(resource_manager.get_resource_type_by_name("metal"),amount,_ai.ai_data.id)
				buy_command.execute() 
		#---------------------------------------------------------------------------------------
		if _ai.ai_data.owned_buildings.has(Tile.Type.MINERALS_FACTORY) == false: 
			amount = 5 
			var buy_command = _ai._command_factory.\
				create_buy_command(resource_manager.get_resource_type_by_name("minerals"),amount,_ai.ai_data.id)
			buy_command.execute()		
		elif _ai.ai_data.owned_buildings.has(Tile.Type.MINERALS_FACTORY) == true and \
			_ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("minerals"))<=max_amount:
				amount = 1
				var buy_command = _ai._command_factory.\
					create_buy_command(resource_manager.get_resource_type_by_name("minerals"),amount,_ai.ai_data.id)
				buy_command.execute()
		#---------------------------------------------------------------------------------------
		if _ai.ai_data.owned_buildings.has(Tile.Type.MINERALS_REFINERY) == false: 
			amount = 5 
			var buy_command = _ai._command_factory.\
				create_buy_command(resource_manager.get_resource_type_by_name("minerals"),amount,_ai.ai_data.id)
			buy_command.execute()		
		elif _ai.ai_data.owned_buildings.has(Tile.Type.MINERALS_REFINERY) == true and \
			_ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("minerals"))<=max_amount:
				amount = 1
				var buy_command = _ai._command_factory.\
					create_buy_command(resource_manager.get_resource_type_by_name("minerals"),amount,_ai.ai_data.id)
				buy_command.execute()
		#--------------------------------------------------------------------------------------
		if _ai.ai_data.owned_buildings.has(Tile.Type.WOOD_REFINERY) == false: 
			amount = 5 
			var buy_command = _ai._command_factory.\
				create_buy_command(resource_manager.get_resource_type_by_name("wood"),amount,_ai.ai_data.id)
			buy_command.execute()		
		elif _ai.ai_data.owned_buildings.has(Tile.Type.WOOD_FACTORY) == true and \
			_ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("wood"))<=max_amount:
				amount = 1
				var buy_command = _ai._command_factory.\
					create_buy_command(resource_manager.get_resource_type_by_name("wood"),amount,_ai.ai_data.id)
				buy_command.execute()
		state_machine.transition_to(IdleState)
	

# ------------------------------------------------------------------------------
class SellResourceState:
	extends State
	
	var resource_manager = Utility.get_dependency("resource_manager", self, true)
	var amount = 5
	const max_amount = 100 
	#to get profit
	
	
	# --------------------------------------------------------------------------
	func update(_delta : float) -> void:
		
		#if it doesnt have a certain thing but the resources for it ^^ 		
		if _ai.ai_data.owned_buildings.has(Tile.Type.WOOD_FACTORY) == true and \
			 _ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("wood"))<=max_amount:
				if _ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("wood"))>=50:
					amount = 10
				else:
					amount = 5 
				var sell_command = _ai._command_factory.\
					create_sell_command(resource_manager.get_resource_type_by_name("wood"),amount,_ai.ai_data.id)
				sell_command.execute()
	
			#---------------------------------------------------------------------------------------			
		if _ai.ai_data.owned_buildings.has(Tile.Type.LUMBER_FACTORY) == true and \
			_ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("lumber"))<=max_amount:
				if _ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("lumber"))>=50:
					amount = 10
				else:
					amount = 5 
				var sell_command = _ai._command_factory.\
					create_sell_command(resource_manager.get_resource_type_by_name("lumber"),amount,_ai.ai_data.id)
				sell_command.execute() 
		#---------------------------------------------------------------------------------------			
		if _ai.ai_data.owned_buildings.has(Tile.Type.METAL_FACTORY) == true and \
			_ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("metal"))<=max_amount:
				if _ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("metal"))>=50:
					amount = 10
				else:
					amount = 5 
				var sell_command = _ai._command_factory.\
					create_sell_command(resource_manager.get_resource_type_by_name("metal"),amount,_ai.ai_data.id)
				sell_command.execute() 
		#---------------------------------------------------------------------------------------			
		if _ai.ai_data.owned_buildings.has(Tile.Type.MINERALS_FACTORY) == true and \
			_ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("minerals"))<=max_amount:
				if _ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("minerals"))>=50:
					amount = 10
				else:
					amount = 5 
				var sell_command = _ai._command_factory.\
					create_sell_command(resource_manager.get_resource_type_by_name("minerals"),amount,_ai.ai_data.id)
				sell_command.execute()
		#---------------------------------------------------------------------------------------
		if _ai.ai_data.owned_buildings.has(Tile.Type.MINERALS_REFINERY) == true and _ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("minerals"))<=max_amount:
			if _ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("minerals"))>=50:
				amount = 10
			else:
				amount = 5 
			var sell_command = _ai._command_factory.\
				create_sell_command(resource_manager.get_resource_type_by_name("minerals"),amount,_ai.ai_data.id)
			sell_command.execute()
		#--------------------------------------------------------------------------------------
		if _ai.ai_data.owned_buildings.has(Tile.Type.WOOD_FACTORY) == true and _ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("wood"))<=max_amount:
			if _ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("wood"))>=50:
				amount = 10
			else:
				amount = 5 
			var sell_command = _ai._command_factory.\
				create_sell_command(resource_manager.get_resource_type_by_name("wood"),amount,_ai.ai_data.id)
			sell_command.execute()
		state_machine.transition_to(IdleState)
		

# ------------------------------------------------------------------------------
