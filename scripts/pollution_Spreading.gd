extends Node2D


onready var tile_map
var _pollute_pos = Vector2.ZERO
var active_pollution = false
var pollut_dict = {health = 9} # pollution tile
var polluted_dict = {health = 9} # for the harvasted tile ^^
var neighbours  = []


func _ready():
	$Timer.start(2)


func polluted_dict(cell : Vector2)->Pollution:
	_pollute_pos = cell
	return _pollute_pos


func get_tile_map(t_map:TileMap) ->void:
	tile_map=t_map


func pollute_cell(cell : Vector2) -> void:
	var type = tile_map.get_cellv(cell)
	if type == Tile.Type.DIRT:
		already_polluted(cell)
				
	if type == Tile.Type.FOREST:
		forest_pollute(cell)

	if type == Tile.Type.GRASS:
		grass_pollute(cell)

	if type == Tile.Type.WATER:
		water_pollute(cell)

	if type == Tile.Type.STONE:
		stone_pollute(cell)


func already_polluted(cell : Vector2) -> void:
	spreading()


func forest_pollute(cell : Vector2) -> void:
		Pollution.count_t += 1
		pollut_dict.health -= 1
		var rde = Pollution.count_t
		print("TREE_COUNT ",rde) 
		if Pollution.count_t >= 10: #max pollution
				tile_map.set_cellv(cell, Tile.Type.DIRT)
				Pollution.tree_pollution += 1
				Pollution.set_tree_pollution(Pollution.tree_pollution)
				Pollution.count_t = 0
				
				_pollute_pos = cell
				spreading()
				print(" tree polluted")


func grass_pollute(cell : Vector2) -> void:
		Pollution.count_g += 1
		pollut_dict.health-=1
		var gres = Pollution.count_g
		print(gres)
		if Pollution.count_g >= 10:
				tile_map.set_cellv(cell, Tile.Type.DIRT)
				Pollution.count_g = 0
				Pollution.grass_pollution+=1
				Pollution.set_grass_pollution(Pollution.grass_pollution)
				
				_pollute_pos = cell
				spreading()
				print(" grass polluted")


func stone_pollute(cell : Vector2) -> void:
	Pollution.count_s += 1
	pollut_dict.health-=1
	var gres = Pollution.count_s
	print(gres)
	if Pollution.count_s >= 10:
		tile_map.set_cellv(cell, Tile.Type.DIRT)
		Pollution.count_s = 0
		Pollution.mountain_pollution+=1
		Pollution.set_mountain_pollution( Pollution.mountain_pollution)#TEDDY
		_pollute_pos = cell
		spreading()
		print(" stone polluted")


func water_pollute(cell : Vector2) -> void:
	Pollution.count_w += 1
	pollut_dict.health-=1
	var gres = Pollution.count_w
	print(gres)
	if Pollution.count_w >= 10:
		tile_map.set_cellv(cell, Tile.Type.DIRT)
		Pollution.count_w = 0
		Pollution.water_pollution+=1
		Pollution.set_water_pollution(Pollution.water_pollution)
		_pollute_pos = cell
		spreading()
		print(" water polluted")


func get_active_pollution(var pollution):
	active_pollution = pollution

# to activtate the pollution spreading
func spreading():
	_on_Timer_timeout()
	

func _on_Timer_timeout():
	print(pollut_dict)
	if pollut_dict.health == 5 or polluted_dict.health == 5:
		neighbours = Utility.get_neighbours(_pollute_pos)
		var random_neightbour = neighbours[randi() % neighbours.size()]
		print(random_neightbour)
		pollute_cell(random_neightbour)
		if  pollut_dict.health <= 0:
				pollut_dict.health = 9
		
						
			
			
	
