extends Control

var inventory : Inventory
var resource_manager

var num_of_stone_tiles_depleted = 0;
var num_of_wood_tiles_depleted = 0;

const MAX_TILES_DEPLETED = 5
var data

const MONEY_NAME = "res://scenes/ui/money.tscn"
const TILE_BROKEN_NAME =  "res://scenes/ui/tile_broken.tscn"
const POWER_OUT_NAME = "res://scenes/ui/power_out.tscn"
const POLLUTION_NAME = "res://scenes/ui/pollution.tscn"
const RESOURCE_OUT_NAME = "res://scenes/ui/resource_out.tscn"

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
	
	var element = ObjectPool.take_node(TILE_BROKEN_NAME)
	self.add_child(element)
	element.get_node("AcceptDialog").dialog_text  = "A wood tile has been depleted"
	element.get_node("AcceptDialog").popup()

func stone_tile_depleted():
	if Network.is_online:
		num_of_stone_tiles_depleted += 1
		if num_of_stone_tiles_depleted >= MAX_TILES_DEPLETED:
			num_of_stone_tiles_depleted = 0
			
			rpc("player_depleted_stone_tiles", get_tree().get_network_unique_id())
	
	var element = ObjectPool.take_node(TILE_BROKEN_NAME)
	self.add_child(element)
	element.get_node("AcceptDialog").dialog_text  = "A stone tile has been depleted"
	element.get_node("AcceptDialog").popup()

func no_money():
	var element = ObjectPool.take_node(MONEY_NAME)
	self.add_child(element)
	element.get_node("AcceptDialog").dialog_text  = "You have gone bakrupt"
	element.get_node("AcceptDialog").popup()
	
	if Network.is_online:
		rpc("player_gone_bankrupt", get_tree().get_network_unique_id())

func no_power():
	var element = ObjectPool.take_node(POWER_OUT_NAME)
	self.add_child(element)
	element.get_node("AcceptDialog").dialog_text  = "You have no power here!"
	element.get_node("AcceptDialog").popup()

func no_resource(name : String):
	var element = ObjectPool.take_node(RESOURCE_OUT_NAME)
	self.add_child(element)
	element.get_node("AcceptDialog").dialog_text  = "You have ran out of " + name
	element.get_node("AcceptDialog").popup()

func low_money():
	var element = ObjectPool.take_node(MONEY_NAME)
	self.add_child(element)
	element.get_node("AcceptDialog").dialog_text  = "Your money is running low"
	element.get_node("AcceptDialog").popup()

func pollution_levels():
	if Pollution.total() == 10 and !pollution_printed_1:
		var element = ObjectPool.take_node(POLLUTION_NAME)
		self.add_child(element)
		element.get_node("AcceptDialog").dialog_text  = "The world is at 10% of pollution"
		element.get_node("AcceptDialog").popup()
		pollution_printed_1 = true
		pollution_printed_5 = false
	elif Pollution.total() >= 25 and Pollution.total() <= 26 and !pollution_printed_2:
		var element = ObjectPool.take_node(POLLUTION_NAME)
		self.add_child(element)
		element.get_node("AcceptDialog").dialog_text  = "The world is at 25% of pollution"
		element.get_node("AcceptDialog").popup()
		pollution_printed_2 = true
		pollution_printed_1 = false
	elif Pollution.total() == 50 and !pollution_printed_3:
		var element = ObjectPool.take_node(POLLUTION_NAME)
		self.add_child(element)
		element.get_node("AcceptDialog").dialog_text  = "The world is at 50% of pollution"
		element.get_node("AcceptDialog").popup()
		pollution_printed_3 = true
		pollution_printed_2 = false
	elif Pollution.total() >= 75 and Pollution.total() <= 76 and !pollution_printed_4:
		var element = ObjectPool.take_node(POLLUTION_NAME)
		self.add_child(element)
		element.get_node("AcceptDialog").dialog_text  = "The world is at 75% of pollution"
		element.get_node("AcceptDialog").popup()
		pollution_printed_4 = true
		pollution_printed_3 = false
	elif Pollution.total() == 100 and !pollution_printed_5:
		var element = ObjectPool.take_node(POLLUTION_NAME)
		self.add_child(element)
		element.get_node("AcceptDialog").dialog_text  = "The world is at 100% of pollution"
		element.get_node("AcceptDialog").popup()
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
	var element = ObjectPool.take_node(MONEY_NAME)
	self.add_child(element)
	element.get_node("AcceptDialog").dialog_text  = "Player "+ str(id) + " has gone bankrupt"
	element.get_node("AcceptDialog").popup()

remote func player_depleted_stone_tiles(id : int):
	var element = ObjectPool.take_node(MONEY_NAME)
	self.add_child(element)
	element.get_node("AcceptDialog").dialog_text  = "Player "+ str(id) + " has depleted 5 stone tiles"
	element.get_node("AcceptDialog").popup()

remote func player_depleted_wood_tiles(id : int):
	var element = ObjectPool.take_node(MONEY_NAME)
	self.add_child(element)
	element.get_node("AcceptDialog").dialog_text  = "Player "+ str(id) + " has depleted 5 wood tiles"
	element.get_node("AcceptDialog").popup()
