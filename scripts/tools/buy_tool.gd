extends Node2D

var _terrain = null
var _inventory = null

var owner_dict = null
var buying = false

onready var label : Label = $Label

onready var tile_map : TileMap = $TileMap

var tile_Prices = { 
	Tile.Type.GRASS: 1000, 
	Tile.Type.WATER: 1500, 
	Tile.Type.FARM: 2000, 
	Tile.Type.FOREST: 3000, 
	Tile.Type.STONE: 3500,
	}

func _ready() -> void:
	_terrain = Utility.get_dependency("terrain", self, true)
	_inventory = Utility.get_dependency("player_data_manager", self, true).local_player_data._inventory
	owner_dict = Utility.get_dependency("player_data_manager", self, true).owner_dict

func _input(event) -> void:
	if event.is_action_pressed("switch_buying"):
		buying = !buying
		label.text = ""
	
	if event.is_action_pressed("select") and buying:
		var mouse_pos = get_global_mouse_position()
		var mouse_tile : Vector2 = _terrain.get_tile_from_global_position(mouse_pos)
		buy_tile(mouse_tile)
	

func buy_tile(tile_pos : Vector2) ->void:
	var id = 1
	if Network.state != Network.State.SOLO:
		id = get_tree().get_network_unique_id()
	
	if !owner_dict.has(tile_pos):
		if _check_price_and_buy(tile_pos):
			owner_dict[tile_pos] = {
			id = id,
			}
			tile_map.set_cellv(tile_pos, owner_dict[tile_pos].id-1)


func _check_price_and_buy(tile_pos : Vector2) ->bool:
	var tile_type = _terrain.get_cellv(tile_pos)
	var tile_price = tile_Prices[tile_type]
	if _inventory.get_money() >= tile_price:
		_inventory.change_money(-tile_price)
		return true
	return false
	

func check_availble(tile_pos : Vector2) ->bool:
	if !owner_dict.has(tile_pos):
		var tile_type = _terrain.get_cellv(tile_pos)
		var tile_price = tile_Prices[tile_type]
		if _inventory.get_money() >= tile_price:
			return true
	return false

func _process(delta):
	if buying:
		var mouse_pos = get_global_mouse_position()
		var mouse_tile : Vector2 = _terrain.get_tile_from_global_position(mouse_pos)
		
		label.rect_position = mouse_pos
		if !owner_dict.has(mouse_tile):
			label.text = str(tile_Prices[_terrain.get_cellv(mouse_tile)])
	
