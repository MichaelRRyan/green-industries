extends ToolInterfaces.BuyTool

var _game_state = null
var _terrain = null
var _inventory = null
var _networked_players = null


var owner_dict = null
var buying = false

onready var label : Label = $Label

onready var tile_map : TileMap = $TileMap

var tile_Prices = { 
	Tile.Type.GRASS: 1000, 
	Tile.Type.WATER: 1500, 
	Tile.Type.MEADOW: 2000, 
	Tile.Type.FOREST: 3000, 
	Tile.Type.STONE: 3500,
	}

func _ready() -> void:
	_terrain = Utility.get_dependency("terrain", self, true)
	_game_state = Utility.get_dependency("game_state", self, true)

	_game_state.connect("selected_tool_changed", self, 
		"_on_game_state_selected_tool_changed")

	var player_data_manager = Utility.get_dependency("player_data_manager", self, true)
	
	#needs to change to specific peer
	_inventory = player_data_manager.local_player_data._inventory
	if Network.is_host():
		_networked_players = player_data_manager.networked_players
	
	owner_dict = player_data_manager.owner_dict
	#_outline_col = player_data_manager.local_player_data.id


func _on_game_state_selected_tool_changed(new_tool : int, _old_tool : int) -> void:
	if Tool.Type.BUY_LAND != new_tool:
		label.text = ""


func _unhandled_input(event) -> void:
	if Tool.Type.BUY_LAND == _game_state.get_selected_tool():
		if event.is_action_pressed("select"):
			var mouse_pos = get_global_mouse_position()
			var mouse_tile : Vector2 = _terrain.get_tile_from_global_position(mouse_pos)
			buy_tile(mouse_tile)
			
	elif event.is_action_pressed("buy_land_tool_shortcut"):
		_game_state.set_selected_tool(Tool.Type.BUY_LAND)


func buy_tile(tile_pos : Vector2) -> void:
	if Network.is_client():
		rpc_id(1, "request_buy", tile_pos, get_tree().get_network_unique_id())
		
	elif _check_price_and_buy(tile_pos, _inventory):
			add_to_owner_dict(tile_pos, 1)
			
			if Network.is_online:
				rpc("add_to_owner_dict", tile_pos, 1)

remote func request_buy(tile_pos : Vector2, id) -> void:
	if !owner_dict.has(tile_pos):
		if _check_price_and_buy(tile_pos, _networked_players[id]._inventory):
			rpc("add_to_owner_dict", tile_pos, id)
			add_to_owner_dict(tile_pos, id)

remote func add_to_owner_dict(tile_pos: Vector2, id) -> void:
	owner_dict[tile_pos] = {
		id = id,
		}
	if Network.state != Network.State.SOLO:
		rpc("sync_owner_tile_map", tile_pos, _networked_players[id].outline_id)
		sync_owner_tile_map(tile_pos, _networked_players[id].outline_id)
	else:
		sync_owner_tile_map(tile_pos, owner_dict[tile_pos].id-1)


remote func sync_owner_tile_map(tile_pos: Vector2, outline_id) -> void:
	tile_map.set_cellv(tile_pos, outline_id)


func _check_price_and_buy(tile_pos : Vector2, inventory) ->bool:
	if !owner_dict.has(tile_pos):
		var tile_type = _terrain.get_cellv(tile_pos)
		var tile_price = tile_Prices[tile_type]
		if inventory.get_money() >= tile_price:
			inventory.change_money(-tile_price)
			return true
		return false
	return false
	

func check_availble(tile_pos : Vector2) -> bool:
	if !owner_dict.has(tile_pos):
		var tile_type = _terrain.get_cellv(tile_pos)
		var tile_price = tile_Prices[tile_type]
		if _inventory.get_money() >= tile_price:
			return true
	return false

	
func _process(_delta):
	if Tool.Type.BUY_LAND == _game_state.get_selected_tool():
		var mouse_pos = get_global_mouse_position()
		var mouse_tile : Vector2 = _terrain.get_tile_from_global_position(mouse_pos)
		
		label.rect_position = mouse_pos
		if !owner_dict.has(mouse_tile):
			label.text = str(tile_Prices[_terrain.get_cellv(mouse_tile)])
	
