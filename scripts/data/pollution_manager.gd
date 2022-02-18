extends Node

signal pollution_maxed
signal cell_polluted(cell)

onready var _terrain = Utility.get_dependency("terrain", self, true)
onready var _player_data_manager = Utility.get_dependency("player_data_manager", self, true)

onready var _pollute_timer : Timer = get_node("PolluteTimer")

const _MAX_POLLUTION = 100.0 # 100 percent.
const _TREES_PER_TILE = 10
const _POLLUTION_DISSIPATION_PER_TREE = 0.00001 # Per second.
const _POLLUTION_INCREASE_PER_BUILDING = 0.05 # Per second.
const _POLLUTION_INCREASE_PER_STONE = 0.8 # Per harvest
const _PERSONAL_POLLUTION_INCREASE_PER_TREE = 0.8 # Per harvest
const _TILE_POLLUTION_THRESHOLD = 15.0 # Pollution Percentage

# Percentage change to pollute a neighbour of the last tile polluted.
const _CHANCE_TO_POLLUTE_NEAR : int = 50

 # The base amount of seconds between tiles becoming polluted.
const _BASE_SECONDS_BETWEEN_POLLUTION = 30.0

var _total_trees = 0
var _pollution_percent = 0.0

var _last_polluted = null # Used to spread pollution more in an area.


#-------------------------------------------------------------------------------
func get_pollution_percent() -> float:
	return _pollution_percent


#-------------------------------------------------------------------------------
# Called from any powered or power producing building.
func increase_pollution(delta : float, building_position : Vector2) -> void:
	
	var pollution_increase = _POLLUTION_INCREASE_PER_BUILDING * delta
	
	# Increases the player's pollution caused.
	# This is inefficient but it works.
	var cell = _terrain.get_tile_from_global_position(building_position)
	if _player_data_manager.owner_dict.has(cell):
		var player_id = _player_data_manager.owner_dict[cell].id
		_player_data_manager.networked_players[player_id].pollution_caused += pollution_increase
	
	_pollute_by_amount(pollution_increase)
	
		
#-------------------------------------------------------------------------------
func _pollute_by_amount(amount : float) -> void:
	_pollution_percent += amount
	
	# Pollution cannot go beyond max pollution.
	_pollution_percent = min(_pollution_percent, _MAX_POLLUTION)
	
	if _pollution_percent >= 100.0:
		emit_signal("pollution_maxed")
	
	# If the pollution threshold has been met and the timer is stopped.
	elif _pollution_percent >= _TILE_POLLUTION_THRESHOLD:
		if _pollute_timer.is_stopped():
			_start_pollute_timer()


#-------------------------------------------------------------------------------
func _start_pollute_timer():
	var speed_modifier = 1.0 - (
		(_pollution_percent - _TILE_POLLUTION_THRESHOLD)
		/ (_MAX_POLLUTION - _TILE_POLLUTION_THRESHOLD))
	
	var wait_time = _BASE_SECONDS_BETWEEN_POLLUTION * speed_modifier
	if wait_time == 0: wait_time = 0.1
	print("Started pollute timer. Wait time: " + str(wait_time))
	_pollute_timer.start(wait_time)


#-------------------------------------------------------------------------------
func _ready() -> void:
	# Finds the world generator and listens for its world generated signal.
	var world_generator = Utility.get_dependency("world_generator", self, true)
	if world_generator:
		world_generator.connect("world_generated", self, "_on_world_generated")
	
	# Finds the terrain and listens for its cell damaged signal.
	var terrain = Utility.get_dependency("terrain", self, true)
	if terrain:
		terrain.connect("cell_damaged", self, "_on_cell_damaged")


#-------------------------------------------------------------------------------
func _process(delta : float) -> void:
	_pollution_percent -= _total_trees * _POLLUTION_DISSIPATION_PER_TREE * delta
	_pollution_percent = max(_pollution_percent, 0) # Pollution cannot go below 0.
	#print("World Pollution: " + str(_pollution_percent) + "%")
	
	
#-------------------------------------------------------------------------------
# Counts the number of trees at world generation.
func _on_world_generated(tiles : Array) -> void:
	_total_trees = 0
	
	for x in range(tiles.size()):
		for y in range(tiles[x].size()):
			if Tile.Type.FOREST == tiles[x][y]:
				_total_trees += _TREES_PER_TILE
	
	print(_total_trees)


#-------------------------------------------------------------------------------
func _on_cell_damaged(cell: Vector2, tile_type : int) -> void:
	# Finds which player owns the tile, if it is owned.
	var player = null
	if _player_data_manager.owner_dict.has(cell):
		var player_id = _player_data_manager.owner_dict[cell].id
		player = _player_data_manager.networked_players[player_id]
	
	# If a tree was damaged, minus one from the tree count.
	if Tile.Type.FOREST == tile_type:
		_total_trees -= 1
		
		if player:
			player.pollution_caused += _PERSONAL_POLLUTION_INCREASE_PER_TREE
		
	# If a stone was damaged, increase the pollution.
	elif Tile.Type.STONE == tile_type:
		if player:
			player.pollution_caused += _POLLUTION_INCREASE_PER_STONE
		
		_pollute_by_amount(_POLLUTION_INCREASE_PER_STONE)
	

#-------------------------------------------------------------------------------
func _on_PolluteTimer_timeout() -> void:
	# The pollution is still above the threshold.
	if _pollution_percent >= _TILE_POLLUTION_THRESHOLD:
		var cell = Vector2()
		var alternative = -1
		var attempts = 0
		var max_attempts = 30
		
		# Loops until a polluted alternative is found for a tile.
		while alternative < 0 and attempts < max_attempts:
			attempts += 1
			
			# If a tile was polluted before the random chance to pollute near hits.
			if _last_polluted != null and randi() % 100 < _CHANCE_TO_POLLUTE_NEAR:
				
				# Tries to find a neigbour to pollute
				var neighbours = Utility.get_neighbours(_last_polluted)
				while not neighbours.empty():
					cell = neighbours[randi() % neighbours.size()]
					neighbours.erase(cell)
					var tile = _terrain.get_cellv(cell)
					
					# Gets the alternative and breaks if it's valid.
					alternative = _get_polluted_alternative(tile)
					if alternative != -1:
						break
			else:
				
				# Picks a random tile.
				cell.x = randi() % _terrain.WIDTH
				cell.y = randi() % _terrain.HEIGHT
				
				var tile = _terrain.get_cellv(cell)
				alternative = _get_polluted_alternative(tile)
		
		if alternative >= 0:
			_last_polluted = cell
			_terrain.set_cellv(cell, alternative)
			emit_signal("cell_polluted", cell)
			
			print("Polluted tile " + str(cell))
		
		_start_pollute_timer()
	

#-------------------------------------------------------------------------------
func _get_polluted_alternative(tile_type : int) -> int:
	match (tile_type):
		Tile.Type.GRASS:
			return Tile.Type.DIRT
		Tile.Type.MEADOW:
			return Tile.Type.PATCHED_GRASS
		Tile.Type.STONE:
			return Tile.Type.CRACKED_STONE
		Tile.Type.FOREST:
			return Tile.Type.DEAD_FOREST
		Tile.Type.WATER:
			return Tile.Type.MURKY_WATER
	
	return -1
	

#-------------------------------------------------------------------------------
