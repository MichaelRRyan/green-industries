extends "res://scripts/classes/abstract_factory_pattern.gd"

class_name WoodHarvesterFactory
func generate_scene(_inventory):
	var purchase_amount = 1000
	if _inventory.get_money() <= purchase_amount:
		return null
	print("Current Money: " + str(_inventory.get_money()))
	_inventory.change_money(-purchase_amount)
	print("Current Money: " + str(_inventory.get_money()))
	return generate_bought_scene()


func generate_bought_scene():
	var scene = load("res://scenes/buildings/lumberjack.tscn")
	var harvester = scene.instance()
	return harvester

func is_able_build(_inventory) -> bool:
	var purchase_amount = 1000
	if _inventory.get_money() >= purchase_amount:
		return true
	return false
