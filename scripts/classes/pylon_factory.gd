extends "res://scripts/classes/abstract_factory_pattern.gd"

class_name PylonFactory
func generate_scene(_inventory):
	if not is_able_build(_inventory):
		return null
	print("Current Money: " + str(_inventory.get_money()))
	_inventory.change_money(-2000)
	return generate_bought_scene()

func is_able_build(_inventory) -> bool:
	var purchase_amount = 2000
	if _inventory.get_money() >= purchase_amount:
		return true
	return false

func generate_bought_scene():
	var scene = load("res://scenes/buildings/pylon.tscn")
	var pylon = scene.instance()
	return pylon
