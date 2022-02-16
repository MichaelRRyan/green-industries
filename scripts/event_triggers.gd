extends Control

var inventory : Inventory
var resource_manager

var num_of_stone_tiles_depleted = 0;
var num_of_wood_tiles_depleted = 0;

const MAX_TILES_DEPLETED = 5
var data

var no_wood_printed : bool
var no_stone_printed : bool
var no_money_printed : bool
var low_money_printed : bool
var pollution_printed_1 : bool
var pollution_printed_2 : bool
var pollution_printed_3 : bool
var pollution_printed_4 : bool
var pollution_printed_5 : bool

func _ready():
	call_deferred("set_up")

func set_up():
	resource_manager = Utility.get_dependency("resource_manager", self, true)
	data = Utility.get_dependency("player_data_manager", self, true).local_player_data
	
	if Network.is_online and get_tree().network_peer != null:
		inventory = data._inventory
	else:
		inventory = data._inventory
	
	var _r # To discard the return value without warnings.
	
	_r = inventory.connect("money_changed", self, 
		"_on_local_player_money_changed")
	
	_r = inventory.connect("resource_changed", self, 
		"_on_local_player_resource_changed")

func wood_tile_depleted():
	if Network.is_online:
		num_of_wood_tiles_depleted += 1
		if num_of_wood_tiles_depleted >= MAX_TILES_DEPLETED:
			num_of_wood_tiles_depleted = 0
			
			rpc("player_depleted_wood_tiles", get_tree().get_network_unique_id())
	
	get_node("AcceptDialog").dialog_text = "A wood tile has been depleted"
	get_node("AcceptDialog").popup()
	get_node("TileBroken").play()

func stone_tile_depleted():
	if Network.is_online:
		num_of_stone_tiles_depleted += 1
		if num_of_stone_tiles_depleted >= MAX_TILES_DEPLETED:
			num_of_stone_tiles_depleted = 0
			rpc("player_depleted_stone_tiles", get_tree().get_network_unique_id())
	
	get_node("AcceptDialog").dialog_text = "A stone tile has been depleted"
	get_node("AcceptDialog").popup()
	get_node("TileBroken").play()

func no_money():
	get_node("AcceptDialog").dialog_text = "You have gone bakrupt"
	get_node("AcceptDialog").popup()
	get_node("Money").play()
	
	if Network.is_online:
		rpc("player_gone_bankrupt", get_tree().get_network_unique_id())

func no_power():
	get_node("AcceptDialog").dialog_text = "You have no power here!"
	get_node("AcceptDialog").popup()
	get_node("PowerOut").play()

func no_resource(name : String):
	get_node("AcceptDialog").dialog_text = "You have ran out of " + name
	get_node("AcceptDialog").popup()
	get_node("ResourceOut").play()

func low_money():
	get_node("AcceptDialog").dialog_text = "Your money is running low"
	get_node("AcceptDialog").popup()
	get_node("Money").play()

func pollution_levels():
	if Pollution.total() == 10 and !pollution_printed_1:
		get_node("AcceptDialog").dialog_text = "You are at 10% of pollution"
		get_node("AcceptDialog").popup()
		get_node("Pollution").play()
		pollution_printed_1 = true
		pollution_printed_5 = false
	elif Pollution.total() >= 25 and Pollution.total() <= 26 and !pollution_printed_2:
		get_node("AcceptDialog").dialog_text = "You are at 25% of pollution"
		get_node("AcceptDialog").popup()
		get_node("Pollution").play()
		pollution_printed_2 = true
		pollution_printed_1 = false
	elif Pollution.total() == 50 and !pollution_printed_3:
		get_node("AcceptDialog").dialog_text = "You are at 50% of pollution"
		get_node("AcceptDialog").popup()
		get_node("Pollution").play()
		pollution_printed_3 = true
		pollution_printed_2 = false
	elif Pollution.total() >= 75 and Pollution.total() <= 76 and !pollution_printed_4:
		get_node("AcceptDialog").dialog_text = "You are at 75% of pollution"
		get_node("AcceptDialog").popup()
		get_node("Pollution").play()
		pollution_printed_4 = true
		pollution_printed_3 = false
	elif Pollution.total() == 100 and !pollution_printed_5:
		get_node("AcceptDialog").dialog_text = "You are at 100% of pollution"
		get_node("AcceptDialog").popup()
		get_node("Pollution").play()
		pollution_printed_5 = true
		pollution_printed_4 = false

func _process(_delta):
	pollution_levels()

func _on_local_player_money_changed(_money : int):
	if _money <= 0:
		no_money()
		
	elif _money < 1000:
		low_money()

func _on_local_player_resource_changed(resource : ResourceType, quantity : int):
	if quantity == 0:
		no_resource(resource.name)

remote func player_gone_bankrupt(id : int):
	get_node("AcceptDialog").dialog_text = "Player "+ str(id) + " has gone bankrupt"
	get_node("AcceptDialog").popup()
	get_node("Money").play()

remote func player_depleted_stone_tiles(id : int):
	get_node("AcceptDialog").dialog_text ="Player "+ str(id) + " has depleted 5 stone tiles"
	get_node("AcceptDialog").popup()
	get_node("TileBroken").play()

remote func player_depleted_wood_tiles(id : int):
	get_node("AcceptDialog").dialog_text = "Player "+ str(id) + " has depleted 5 wood tiles"
	get_node("AcceptDialog").popup()
	get_node("TileBroken").play()
