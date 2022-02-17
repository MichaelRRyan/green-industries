extends Node


var save_dictionary = {}

func save_all():
	var player_data_manager =  Utility.get_dependency("player_data_manager")
	if player_data_manager:
		player_data_manager.accept(self)
	var terrain =  Utility.get_dependency("terrain")
	if terrain:
		terrain.accept(self)	
	save_pollution()

# to save the owner dictonary ^^ ------------------------------------------
func save_player_data_manager(player_data_manager):
	var resources = player_data_manager.local_player_data._inventory._resources
	var rec_dict = {}
	var net_dict = {}
	for r in resources.keys():
		rec_dict[r.name] = resources[r]
	var network =  player_data_manager.networked_players
	for n in network.keys():
		net_dict[n] = network[n]
		
	save_dictionary["owner_dict"] = player_data_manager.owner_dict
	save_dictionary["inventory_resources"] = rec_dict
	save_dictionary["inventory_money"] = player_data_manager.local_player_data._inventory._money
	save_dictionary["networked_players"] = net_dict
	
func save_pollution():
	save_dictionary["pollution_level"] = Pollution.total()

func save_terrain(terrain):
	save_dictionary["terrain"] = terrain.get_tiles()
	
func _input(_event):
	if Input.is_action_pressed("pollution_level"):
		print("saved")
		call_deferred("save_all")
