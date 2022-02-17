class_name States

#basic standby wait state when no decision needed
class IdleState:
	extends State
	
	var ai = null
	
	func enter(parent) -> void:
		ai = parent
		print ("Entered idle")
	
	func exit(_msg : = {}) -> void:
		print ("Exited idle")
		queue_free()
	
	func update(_delta : float) -> void:
		pass

#state to start the AI off
class StartState:
	extends State
	
	var ai = null
	
	func enter(parent) -> void:
		ai = parent
		print ("Entered start state")
	
	func exit(_msg : = {}) -> void:
		print ("Exited  start state")
		queue_free()
	
	func update(_delta : float) -> void:
		var buy_tile : Vector2 = Vector2(randi() % ai.TILE_MAP_SIZE, randi() % ai.TILE_MAP_SIZE)
		var still_looking = true
		while ai._player_data_manager.owner_dict.has(buy_tile) or still_looking:
			buy_tile = Vector2(randi() % ai.TILE_MAP_SIZE, randi() % ai.TILE_MAP_SIZE)
			var neighbours = Utility.get_neighbours(buy_tile)
			var contains_trees = false
			var contains_minerals = false
			for neighbour in neighbours:
				if ai._terrain.get_cellv(neighbour) == Tile.Type.FOREST:
					contains_trees = true
				elif ai._terrain.get_cellv(neighbour) == Tile.Type.STONE:
					contains_minerals = true
			if ai._terrain.get_cellv(buy_tile) == Tile.Type.GRASS and\
				(contains_trees or contains_minerals):
					still_looking = false
		var command = ai._command_factory.create_buy_land_command(buy_tile, ai.ai_data.id)
		command.execute()
		ai.controlled_tiles.push_back(buy_tile)
		ai._wait_timer.start()
		ai._place_building_timer.start()

#state to buy land when all land is used up or ai has no land
class BuyLandState:
	extends State
	
	var ai
	
	func enter(parent) -> void:
		ai = parent
		print ("Entered no land state")
	
	func exit(_msg : = {}) -> void:
		print ("Exited no land state")
		queue_free()
	
	func update(_delta : float) -> void:
		var neighbours = Utility.get_neighbours(ai.controlled_tiles.back())
		var _buy_tile
		
		for neighbour in neighbours:
			if ai._terrain.get_cellv(neighbour) == Tile.Type.FOREST or\
				ai._terrain.get_cellv(neighbour) == Tile.Type.STONE:
					_buy_tile = neighbour
					break
		if _buy_tile != null:
			var command = ai._command_factory.create_buy_land_command(_buy_tile, ai.ai_data.id)
			command.execute()
			ai.controlled_tiles.push_back(_buy_tile)
		ai._wait_timer.start()

#state to place harvester when no resources are had
class PlaceHarvesterState:
	extends State
	
	var ai = null
		
	func enter(parent) -> void:
		ai = parent
		print ("Entered place harvester state")
	
	func exit(_msg : = {}) -> void:
		print ("Exited place harvester state")
		queue_free()
	
	func update(_delta : float) -> void:
		var neighbours = Utility.get_neighbours(ai.controlled_tiles.back())
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
		var buy_tile : Vector2 = Vector2(randi() % ai.TILE_MAP_SIZE, randi() % ai.TILE_MAP_SIZE)
		for neighbour in neighbours:
			if ai._terrain.get_cellv(neighbour) == Tile.Type.FOREST and build_type == Tile.Type.LUMBERJACK:
				buy_tile = neighbour
				break
			elif ai._terrain.get_cellv(neighbour) == Tile.Type.STONE and build_type == Tile.Type.MINE:
				buy_tile = neighbour
				break
		if build_type != null:
			var command = ai._command_factory.\
				create_build_command(ai.controlled_tiles.back(), build_type, ai.ai_data.id)
			command.execute()
			ai._wait_timer.start()
			ai._timer.start()

#state to power a power plant when its out of fuel
class NoPowerState:
	extends State
	
	var ai = null
	
	func enter(parent) -> void:
		ai = parent
		print ("Entered no power state")
	
	func exit(_msg : = {}) -> void:
		print ("Exited no power state")
		queue_free()
	
	func update(_delta : float) -> void:
		if ai.ai_data._owned_buildings.has(Tile.Type.POWER_PLANT):
			ai.ai_data._owned_buildings.has(Tile.Type.POWER_PLANT).increase_fuel()
			
		elif ai.ai_data._owned_buildings.has(Tile.Type.WOOD_REFINERY):
			var tile_pos = ai.ai_data._owned_buildings.has(Tile.Type.WOOD_REFINERY)
			var neighbours = Utility.get_neighbours(tile_pos)
			
			for neighbour in neighbours:
				if ai._terrain.get_cellv(neighbour) == Tile.Type.GRASS:
					var command = ai._command_factory.\
					create_build_command(neighbour, Tile.Type.POWER_PLANT, ai.ai_data.id)
					command.execute()
					break
			
		elif ai.ai_data._owned_buildings.has(Tile.Type.MINERALS_REFINERY):
			var tile_pos = ai.ai_data._owned_buildings.has(Tile.Type.MINERALS_REFINERY)
			var neighbours = Utility.get_neighbours(tile_pos)
			
			for neighbour in neighbours:
				if ai._terrain.get_cellv(neighbour) == Tile.Type.GRASS:
					var command = ai._command_factory.\
					create_build_command(neighbour, Tile.Type.POWER_PLANT, ai.ai_data.id)
					command.execute()
					break
			
		elif ai.ai_data._owned_buildings.has(Tile.Type.WOOD_FACTORY):
			var tile_pos = ai.ai_data._owned_buildings.has(Tile.Type.WOOD_FACTORY)
			var neighbours = Utility.get_neighbours(tile_pos)
			
			for neighbour in neighbours:
				if ai._terrain.get_cellv(neighbour) == Tile.Type.GRASS:
					var command = ai._command_factory.\
					create_build_command(neighbour, Tile.Type.POWER_PLANT, ai.ai_data.id)
					command.execute()
					break
			
		elif ai.ai_data._owned_buildings.has(Tile.Type.MINERALS_FACTORY):
			var tile_pos = ai.ai_data._owned_buildings.has(Tile.Type.MINERALS_FACTORY)
			var neighbours = Utility.get_neighbours(tile_pos)
			
			for neighbour in neighbours:
				if ai._terrain.get_cellv(neighbour) == Tile.Type.GRASS:
					var command = ai._command_factory.\
					create_build_command(neighbour, Tile.Type.POWER_PLANT, ai.ai_data.id)
					command.execute()
					break
			
		elif ai.ai_data._owned_buildings.has(Tile.Type.METAL_FACTORY):
			var tile_pos = ai.ai_data._owned_buildings.has(Tile.Type.METAL_FACTORY)
			var neighbours = Utility.get_neighbours(tile_pos)
			
			for neighbour in neighbours:
				if ai._terrain.get_cellv(neighbour) == Tile.Type.GRASS:
					var command = ai._command_factory.\
					create_build_command(neighbour, Tile.Type.POWER_PLANT, ai.ai_data.id)
					command.execute()
					break
			
		elif ai.ai_data._owned_buildings.has(Tile.Type.LUMBER_FACTORY):
			var tile_pos = ai.ai_data._owned_buildings.has(Tile.Type.LUMBER_FACTORY)
			var neighbours = Utility.get_neighbours(tile_pos)
			
			for neighbour in neighbours:
				if ai._terrain.get_cellv(neighbour) == Tile.Type.GRASS:
					var command = ai._command_factory.\
					create_build_command(neighbour, Tile.Type.POWER_PLANT, ai.ai_data.id)
					command.execute()
					break
		
		ai._wait_timer.start()

#state to find a place nearby and to place specific refinary
class PlaceRefinaryState:
	extends State
	
	var resource_manager = Utility.get_dependency("resource_manager", self, true)
	var ai = null
	
	func enter(parent) -> void:
		ai = parent
		print ("Entered place refinary state")
	
	func exit(_msg : = {}) -> void:
		print ("Exited place refinary state")
		queue_free()
	
	func update(_delta : float) -> void:
		if ai.controlled_tiles.has(Tile.Type.GRASS):
			var _tile_pos = ai.controlled_tiles.find(Tile.Type.GRASS)
			
			if ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("wood")) > 0 \
				and !ai.ai_data._owned_buildings.has(Tile.Type.WOOD_REFINERY):
					var command = ai._command_factory.\
					create_build_command(_tile_pos, Tile.Type.WOOD_REFINERY, ai.ai_data.id)
					command.execute()
			elif ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("minerals")) > 0 \
				and !ai.ai_data._owned_buildings.has(Tile.Type.MINERALS_REFINERY):
					var command = ai._command_factory.\
					create_build_command(_tile_pos, Tile.Type.MINERALS_REFINERY, ai.ai_data.id)
					command.execute()
			
		ai._wait_timer.start()

#state to find a place nearby and to place specific refinary
class PlaceFactoryState:
	extends State
	
	var resource_manager = Utility.get_dependency("resource_manager", self, true)
	var ai = null
	
	func enter(parent) -> void:
		ai = parent
		print ("Entered place refinary state")
	
	func exit(_msg : = {}) -> void:
		print ("Exited place refinary state")
		queue_free()
	
	func update(_delta : float) -> void:
		if ai.controlled_tiles.has(Tile.Type.GRASS):
			var _tile_pos = ai.controlled_tiles.find(Tile.Type.GRASS)
			
			if ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("wood")) > 0 \
				and !ai.ai_data._owned_buildings.has(Tile.Type.WOOD_FACTORY):
					var command = ai._command_factory.\
					create_build_command(_tile_pos, Tile.Type.WOOD_FACTORY, ai.ai_data.id)
					command.execute()
				
			elif ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("minerals")) > 0 \
				and !ai.ai_data._owned_buildings.has(Tile.Type.MINERALS_FACTORY):
					var command = ai._command_factory.\
					create_build_command(_tile_pos, Tile.Type.MINERALS_FACTORY, ai.ai_data.id)
					command.execute()
				
			elif ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("lumber")) > 0 \
				and !ai.ai_data._owned_buildings.has(Tile.Type.LUMBER_FACTORY):
					var command = ai._command_factory.\
					create_build_command(_tile_pos, Tile.Type.LUMBER_FACTORY, ai.ai_data.id)
					command.execute()
				
			elif ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("metal")) > 0 \
				and !ai.ai_data._owned_buildings.has(Tile.Type.METAL_FACTORY):
					var command = ai._command_factory.\
					create_build_command(_tile_pos, Tile.Type.METAL_FACTORY, ai.ai_data.id)
					command.execute()
			
			
		ai._wait_timer.start()

#state to give resources to refinary to get the better resource
class GiveResourceToRefinaryState:
	extends State
	
	var resource_manager = Utility.get_dependency("resource_manager", self, true)
	var ai = null
	
	func enter(parent) -> void:
		ai = parent
		print ("Entered give resource to refinary state")
	
	func exit(_msg : = {}) -> void:
		print ("Exited give resource to refinary state")
		queue_free()
	
	func update(_delta : float) -> void:
		if ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("wood")) > 0 \
			and ai.ai_data._owned_buildings.has(Tile.Type.WOOD_REFINERY):
				ai.ai_data._owned_buildings.has(Tile.Type.WOOD_REFINERY)._input_ingredients()
		if ai.ai_data._inventory.get_quantity(resource_manager.get_resource_type_by_name("minerals")) > 0 \
			and ai.ai_data._owned_buildings.has(Tile.Type.MINERALS_REFINERY):
				ai.ai_data._owned_buildings.has(Tile.Type.MINERALS_REFINERY)._input_ingredients()
			
		ai._wait_timer.start()
