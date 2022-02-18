class_name States

#basic standby wait state when no decision needed
class IdleState:
	extends State
	
	var ai = null
	
	func enter(parent) -> void:
		ai = parent
	
	func exit(_msg : = {}) -> void:
		queue_free()
	
	func update(_delta : float) -> void:
		pass

#state to start the AI off
class StartState:
	extends State
	
	var ai = null
	
	func enter(parent) -> void:
		ai = parent
	
	func exit(_msg : = {}) -> void:
		queue_free()
	
	func update(_delta : float) -> void:
		var _buy_tile : Vector2 = Vector2(randi() % ai.TILE_MAP_SIZE, randi() % ai.TILE_MAP_SIZE)
		var still_looking = true
		while ai._player_data_manager.owner_dict.has(_buy_tile) or still_looking:
			_buy_tile = Vector2(randi() % ai.TILE_MAP_SIZE, randi() % ai.TILE_MAP_SIZE)
			var neighbours = Utility.get_neighbours(_buy_tile)
			var contains_trees = false
			var contains_minerals = false
			for neighbour in neighbours:
				if ai._terrain.get_cellv(neighbour) == Tile.Type.FOREST:
					contains_trees = true
				elif ai._terrain.get_cellv(neighbour) == Tile.Type.STONE:
					contains_minerals = true
			if ai._terrain.get_cellv(_buy_tile) == Tile.Type.GRASS and\
				(contains_trees or contains_minerals):
					still_looking = false
		var command = ai._command_factory.create_buy_land_command(_buy_tile, ai.ai_data.id)
		command.execute()
		ai.add_to_controlled(_buy_tile)
		ai._wait_timer.start()
		ai._place_building_timer.start()

#state to buy land when all land is used up or ai has no land
class BuyLandState:
	extends State
	
	var ai
	
	func enter(parent) -> void:
		ai = parent
	
	func exit(_msg : = {}) -> void:
		queue_free()
	
	func update(_delta : float) -> void:
		var neighbours = Utility.get_neighbours(ai.controlled_tiles.front())
		var _buy_tile
		var _resource_tile_found = false
		for neighbour in neighbours:
			if ai._terrain.get_cellv(neighbour) == Tile.Type.FOREST or\
				ai._terrain.get_cellv(neighbour) == Tile.Type.STONE:
					_buy_tile = neighbour
					_resource_tile_found = true
					break
			
		if _buy_tile != null:
			var command = ai._command_factory.create_buy_land_command(_buy_tile, ai.ai_data.id)
			command.execute()
			ai.add_to_controlled(_buy_tile)
		ai._wait_timer.start()
		ai.start_transitions = true

class BuyEmptyLandState:
	extends State
	
	var ai
	
	func enter(parent) -> void:
		ai = parent
	
	func exit(_msg : = {}) -> void:
		queue_free()
	
	func update(_delta : float) -> void:
		var neighbours = Utility.get_neighbours(ai.controlled_tiles.front())
		var _buy_tile
		for neighbour in neighbours:
			if ai._terrain.get_cellv(neighbour) == Tile.Type.GRASS:
					_buy_tile = neighbour
					break
			
		if _buy_tile != null:
			var command = ai._command_factory.create_buy_land_command(_buy_tile, ai.ai_data.id)
			command.execute()
			ai.add_to_controlled(_buy_tile)
		ai._wait_timer.start()

#state to place harvester when no resources are had
class PlaceHarvesterState:
	extends State
	
	var ai = null
		
	func enter(parent) -> void:
		ai = parent
	
	func exit(_msg : = {}) -> void:
		queue_free()
	
	func update(_delta : float) -> void:
		var neighbours = Utility.get_neighbours(ai.controlled_tiles.front())
		var contains_trees = false
		var contains_minerals = false
		for neighbour in neighbours:
			if ai._terrain.get_cellv(neighbour) == Tile.Type.FOREST:
				contains_trees = true
			elif ai._terrain.get_cellv(neighbour) == Tile.Type.STONE:
				contains_minerals = true
		var build_type = null
		if contains_trees:
			build_type = Tile.Type.LUMBERJACK
		elif contains_minerals:
			build_type = Tile.Type.MINE
		var _buy_tile : Vector2 = Vector2(randi() % ai.TILE_MAP_SIZE, randi() % ai.TILE_MAP_SIZE)
		for neighbour in neighbours:
			if ai._terrain.get_cellv(neighbour) == Tile.Type.FOREST and build_type == Tile.Type.LUMBERJACK:
				_buy_tile = neighbour
				break
			elif ai._terrain.get_cellv(neighbour) == Tile.Type.STONE and build_type == Tile.Type.MINE:
				_buy_tile = neighbour
				break
		if build_type != null:
			var command = ai._command_factory.\
				create_build_command(ai.controlled_tiles.front(), build_type, ai.ai_data.id)
			
			command.execute()
			ai.change_type(ai.controlled_tiles.front(), build_type)
			ai._wait_timer.start()
			ai._timer.start()

#state to power a power plant when its out of fuel
class NoPowerState:
	extends State
	
	var ai = null
	
	func enter(parent) -> void:
		ai = parent
	
	func exit(_msg : = {}) -> void:
		queue_free()
	
	func update(_delta : float) -> void:
		if ai.controlled_tiles_dict.has(Tile.Type.POWER_PLANT):
			ai.ai_data.owned_buildings[Tile.Type.POWER_PLANT].front().increase_fuel(5)
			
		elif ai.ai_data.owned_buildings.has(Tile.Type.WOOD_REFINERY):
			var tile_pos = ai._terrain.get_tile_from_global_position(\
				ai.ai_data.owned_buildings[Tile.Type.WOOD_REFINERY].front().position)
			var neighbours = Utility.get_neighbours(tile_pos)
			
			for neighbour in neighbours:
				if ai._terrain.get_cellv(neighbour) == Tile.Type.GRASS:
					var command = ai._command_factory.\
					create_build_command(neighbour, Tile.Type.POWER_PLANT, ai.ai_data.id)
					command.execute()
					ai.change_type(neighbour, Tile.Type.POWER_PLANT)
					break
			
		elif ai.ai_data.owned_buildings.has(Tile.Type.MINERALS_REFINERY):
			var tile_pos = ai._terrain.get_tile_from_global_position(\
				ai.ai_data.owned_buildings[Tile.Type.MINERALS_REFINERY].front().position)
			var neighbours = Utility.get_neighbours(tile_pos)
			
			for neighbour in neighbours:
				if ai._terrain.get_cellv(neighbour) == Tile.Type.GRASS:
					var command = ai._command_factory.\
					create_build_command(neighbour, Tile.Type.POWER_PLANT, ai.ai_data.id)
					command.execute()
					ai.change_type(neighbour, Tile.Type.POWER_PLANT)
					break
			
		elif ai.ai_data.owned_buildings.has(Tile.Type.WOOD_FACTORY):
			var tile_pos = ai._terrain.get_tile_from_global_position(\
				ai.ai_data.owned_buildings[Tile.Type.WOOD_FACTORY].front().position)
			var neighbours = Utility.get_neighbours(tile_pos)
			
			for neighbour in neighbours:
				if ai._terrain.get_cellv(neighbour) == Tile.Type.GRASS:
					var command = ai._command_factory.\
					create_build_command(neighbour, Tile.Type.POWER_PLANT, ai.ai_data.id)
					command.execute()
					ai.change_type(neighbour, Tile.Type.POWER_PLANT)
					break
			
		elif ai.ai_data.owned_buildings.has(Tile.Type.MINERALS_FACTORY):
			var tile_pos = ai._terrain.get_tile_from_global_position(\
				ai.ai_data.owned_buildings[Tile.Type.MINERALS_FACTORY].front().position)
			var neighbours = Utility.get_neighbours(tile_pos)
			
			for neighbour in neighbours:
				if ai._terrain.get_cellv(neighbour) == Tile.Type.GRASS:
					var command = ai._command_factory.\
					create_build_command(neighbour, Tile.Type.POWER_PLANT, ai.ai_data.id)
					command.execute()
					ai.change_type(neighbour, Tile.Type.POWER_PLANT)
					break
			
		elif ai.ai_data.owned_buildings.has(Tile.Type.METAL_FACTORY):
			var tile_pos = ai._terrain.get_tile_from_global_position(\
				ai.ai_data.owned_buildings[Tile.Type.METAL_FACTORY].front().position)
			var neighbours = Utility.get_neighbours(tile_pos)
			
			for neighbour in neighbours:
				if ai._terrain.get_cellv(neighbour) == Tile.Type.GRASS:
					var command = ai.command_factory.\
					create_build_command(neighbour, Tile.Type.POWER_PLANT, ai.ai_data.id)
					command.execute()
					ai.change_type(neighbour, Tile.Type.POWER_PLANT)
					break
			
		elif ai.ai_data.owned_buildings.has(Tile.Type.LUMBER_FACTORY):
			var tile_pos = ai._terrain.get_tile_from_global_position(\
				ai.ai_data.owned_buildings[Tile.Type.LUMBER_FACTORY].front().position)
			var neighbours = Utility.get_neighbours(tile_pos)
			
			for neighbour in neighbours:
				if ai._terrain.get_cellv(neighbour) == Tile.Type.GRASS:
					var command = ai.command_factory.\
					create_build_command(neighbour, Tile.Type.POWER_PLANT, ai.ai_data.id)
					command.execute()
					ai.change_type(neighbour, Tile.Type.POWER_PLANT)
					break
		
		ai._wait_timer.start()

#state to find a place nearby and to place specific refinary
class PlaceRefinaryState:
	extends State
	
	var resource_manager = Utility.get_dependency("resource_manager", self, true)
	var ai = null
	
	func enter(parent) -> void:
		ai = parent
	
	func exit(_msg : = {}) -> void:
		queue_free()
	
	func update(_delta : float) -> void:
		if ai.controlled_tiles_dict.has(Tile.Type.GRASS):
			var _tile_pos = ai.controlled_tiles_dict[Tile.Type.GRASS].front()
			
			if ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("wood")) > 0 \
				and !ai.controlled_tiles_dict.has(Tile.Type.WOOD_REFINERY):
					var command = ai._command_factory.\
					create_build_command(_tile_pos, Tile.Type.WOOD_REFINERY, ai.ai_data.id)
					command.execute()
					ai.change_type(_tile_pos, Tile.Type.WOOD_REFINERY)
			elif ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("minerals")) > 0 \
				and !ai.controlled_tiles_dict.has(Tile.Type.MINERALS_REFINERY):
					var command = ai._command_factory.\
					create_build_command(_tile_pos, Tile.Type.MINERALS_REFINERY, ai.ai_data.id)
					command.execute()
					ai.change_type(_tile_pos, Tile.Type.MINERALS_REFINERY)
			
		ai._wait_timer.start()

#state to find a place nearby and to place specific refinary
class PlaceFactoryState:
	extends State
	
	var resource_manager = Utility.get_dependency("resource_manager", self, true)
	var ai = null
	
	func enter(parent) -> void:
		ai = parent
	
	func exit(_msg : = {}) -> void:
		queue_free()
	
	func update(_delta : float) -> void:
		if ai.controlled_tiles_dict.has(Tile.Type.GRASS):
			var _tile_pos = ai.controlled_tiles_dict[Tile.Type.GRASS].front()
			
			if ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("wood")) > 0 \
				and !ai.controlled_tiles_dict.has(Tile.Type.WOOD_FACTORY):
					var command = ai._command_factory.\
					create_build_command(_tile_pos, Tile.Type.WOOD_FACTORY, ai.ai_data.id)
					command.execute()
					ai.change_type(_tile_pos, Tile.Type.WOOD_FACTORY)
				
			elif ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("minerals")) > 0 \
				and !ai.controlled_tiles_dict.has(Tile.Type.MINERALS_FACTORY):
					var command = ai._command_factory.\
					create_build_command(_tile_pos, Tile.Type.MINERALS_FACTORY, ai.ai_data.id)
					command.execute()
					ai.change_type(_tile_pos, Tile.Type.MINERALS_FACTORY)
				
			elif ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("lumber")) > 0 \
				and !ai.controlled_tiles_dict.has(Tile.Type.LUMBER_FACTORY):
					var command = ai._command_factory.\
					create_build_command(_tile_pos, Tile.Type.LUMBER_FACTORY, ai.ai_data.id)
					command.execute()
					ai.change_type(_tile_pos, Tile.Type.LUMBER_FACTORY)
				
			elif ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("metal")) > 0 \
				and !ai.controlled_tiles_dict.has(Tile.Type.METAL_FACTORY):
					var command = ai._command_factory.\
					create_build_command(_tile_pos, Tile.Type.METAL_FACTORY, ai.ai_data.id)
					command.execute()
					ai.change_type(_tile_pos, Tile.Type.METAL_FACTORY)
			
			
		ai._wait_timer.start()

#state to give resources to refinary to get the better resource
class GiveResourceToRefinaryState:
	extends State
	
	var resource_manager = Utility.get_dependency("resource_manager", self, true)
	var ai = null
	
	func enter(parent) -> void:
		ai = parent
	
	func exit(_msg : = {}) -> void:
		queue_free()
	
	func update(_delta : float) -> void:
		if ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("wood")) > 0 \
			and ai.controlled_tiles_dict.has(Tile.Type.WOOD_REFINERY):
				ai.controlled_tiles_dict.has(Tile.Type.WOOD_REFINERY)._input_ingredients()
		if ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("minerals")) > 0 \
			and ai.controlled_tiles_dict.has(Tile.Type.MINERALS_REFINERY):
				ai.controlled_tiles_dict.has(Tile.Type.MINERALS_REFINERY)._input_ingredients()
			
		ai._wait_timer.start()

class BuyResourceState:
	extends State
	
	var resource_manager = Utility.get_dependency("resource_manager", self, true)
	var ai = null
	var amount = 5
	const max_amount = 100
	
	func enter(parent) -> void:
		ai = parent
	
	func exit(_msg : = {}) -> void:
		queue_free()
	
	func update(_delta : float) -> void:
		
		#if it doesnt have a certain thing but the resources for it ^^ 
		if ai.ai_data.owned_buildings.has(Tile.Type.WOOD_FACTORY) == false: 
			amount = 5 
			var buy_command = ai._command_factory.\
				create_buy_command(resource_manager.get_resource_type_by_name("wood"),amount,ai.ai_data.id)
			buy_command.execute()		
		elif ai.ai_data.owned_buildings.has(Tile.Type.WOOD_FACTORY) == true and \
			ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("wood"))<=max_amount:
				amount = 1
				var buy_command = ai._command_factory.\
					create_buy_command(resource_manager.get_resource_type_by_name("wood"),amount,ai.ai_data.id)
				buy_command.execute()
	
			#---------------------------------------------------------------------------------------
		if ai.ai_data.owned_buildings.has(Tile.Type.LUMBER_FACTORY) == false: 
			amount = 5 
			var buy_command = ai._command_factory.\
				create_buy_command(resource_manager.get_resource_type_by_name("lumber"),amount,ai.ai_data.id)
			buy_command.execute()		
		if ai.ai_data.owned_buildings.has(Tile.Type.LUMBER_FACTORY) == true and \
			 ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("lumber"))<=max_amount:
				amount = 1
				var buy_command = ai._command_factory.\
					create_buy_command(resource_manager.get_resource_type_by_name("lumber"),amount,ai.ai_data.id)
				buy_command.execute() 
		#---------------------------------------------------------------------------------------
		if ai.ai_data.owned_buildings.has(Tile.Type.METAL_FACTORY) == false: 
			amount = 5 
			var buy_command = ai._command_factory.\
				create_buy_command(resource_manager.get_resource_type_by_name("metal"),amount,ai.ai_data.id)
			buy_command.execute()		
		if ai.ai_data.owned_buildings.has(Tile.Type.METAL_FACTORY) == true and \
			 ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("metal"))<=max_amount:
				amount = 1
				var buy_command = ai._command_factory.\
					create_buy_command(resource_manager.get_resource_type_by_name("metal"),amount,ai.ai_data.id)
				buy_command.execute() 
		#---------------------------------------------------------------------------------------
		if ai.ai_data.owned_buildings.has(Tile.Type.MINERALS_FACTORY) == false: 
			amount = 5 
			var buy_command = ai._command_factory.\
				create_buy_command(resource_manager.get_resource_type_by_name("minerals"),amount,ai.ai_data.id)
			buy_command.execute()		
		elif ai.ai_data.owned_buildings.has(Tile.Type.MINERALS_FACTORY) == true and \
			ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("minerals"))<=max_amount:
				amount = 1
				var buy_command = ai._command_factory.\
					create_buy_command(resource_manager.get_resource_type_by_name("minerals"),amount,ai.ai_data.id)
				buy_command.execute()
		#---------------------------------------------------------------------------------------
		if ai.ai_data.owned_buildings.has(Tile.Type.MINERALS_REFINERY) == false: 
			amount = 5 
			var buy_command = ai._command_factory.\
				create_buy_command(resource_manager.get_resource_type_by_name("minerals"),amount,ai.ai_data.id)
			buy_command.execute()		
		elif ai.ai_data.owned_buildings.has(Tile.Type.MINERALS_REFINERY) == true and \
			ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("minerals"))<=max_amount:
				amount = 1
				var buy_command = ai._command_factory.\
					create_buy_command(resource_manager.get_resource_type_by_name("minerals"),amount,ai.ai_data.id)
				buy_command.execute()
		#--------------------------------------------------------------------------------------
		if ai.ai_data.owned_buildings.has(Tile.Type.WOOD_REFINERY) == false: 
			amount = 5 
			var buy_command = ai._command_factory.\
				create_buy_command(resource_manager.get_resource_type_by_name("wood"),amount,ai.ai_data.id)
			buy_command.execute()		
		elif ai.ai_data.owned_buildings.has(Tile.Type.WOOD_FACTORY) == true and \
			ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("wood"))<=max_amount:
				amount = 1
				var buy_command = ai._command_factory.\
					create_buy_command(resource_manager.get_resource_type_by_name("wood"),amount,ai.ai_data.id)
				buy_command.execute()
		ai._wait_timer.start()
	

class SellResourceState:
	extends State
	
	var resource_manager = Utility.get_dependency("resource_manager", self, true)
	var ai = null
	var amount = 5
	const max_amount = 100 
	#to get profit
	func enter(parent) -> void:
		ai = parent
	
	func exit(_msg : = {}) -> void:
		queue_free()

	func update(_delta : float) -> void:
		
		#if it doesnt have a certain thing but the resources for it ^^ 		
		if ai.ai_data.owned_buildings.has(Tile.Type.WOOD_FACTORY) == true and \
			 ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("wood"))<=max_amount:
				if ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("wood"))>=50:
					amount = 10
				else:
					amount = 5 
				var sell_command = ai._command_factory.\
					create_sell_command(resource_manager.get_resource_type_by_name("wood"),amount,ai.ai_data.id)
				sell_command.execute()
	
			#---------------------------------------------------------------------------------------			
		if ai.ai_data.owned_buildings.has(Tile.Type.LUMBER_FACTORY) == true and \
			ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("lumber"))<=max_amount:
				if ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("lumber"))>=50:
					amount = 10
				else:
					amount = 5 
				var sell_command = ai._command_factory.\
					create_sell_command(resource_manager.get_resource_type_by_name("lumber"),amount,ai.ai_data.id)
				sell_command.execute() 
		#---------------------------------------------------------------------------------------			
		if ai.ai_data.owned_buildings.has(Tile.Type.METAL_FACTORY) == true and \
			ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("metal"))<=max_amount:
				if ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("metal"))>=50:
					amount = 10
				else:
					amount = 5 
				var sell_command = ai._command_factory.\
					create_sell_command(resource_manager.get_resource_type_by_name("metal"),amount,ai.ai_data.id)
				sell_command.execute() 
		#---------------------------------------------------------------------------------------			
		if ai.ai_data.owned_buildings.has(Tile.Type.MINERALS_FACTORY) == true and \
			ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("minerals"))<=max_amount:
				if ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("minerals"))>=50:
					amount = 10
				else:
					amount = 5 
				var sell_command = ai._command_factory.\
					create_sell_command(resource_manager.get_resource_type_by_name("minerals"),amount,ai.ai_data.id)
				sell_command.execute()
		#---------------------------------------------------------------------------------------
		if ai.ai_data.owned_buildings.has(Tile.Type.MINERALS_REFINERY) == true and ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("minerals"))<=max_amount:
			if ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("minerals"))>=50:
				amount = 10
			else:
				amount = 5 
			var sell_command = ai._command_factory.\
				create_sell_command(resource_manager.get_resource_type_by_name("minerals"),amount,ai.ai_data.id)
			sell_command.execute()
		#--------------------------------------------------------------------------------------
		if ai.ai_data.owned_buildings.has(Tile.Type.WOOD_FACTORY) == true and ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("wood"))<=max_amount:
			if ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("wood"))>=50:
				amount = 10
			else:
				amount = 5 
			var sell_command = ai._command_factory.\
				create_sell_command(resource_manager.get_resource_type_by_name("wood"),amount,ai.ai_data.id)
			sell_command.execute()
		ai._wait_timer.start()
		
