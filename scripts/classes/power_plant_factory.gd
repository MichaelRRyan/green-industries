extends "res://scripts/classes/abstract_factory_pattern.gd"

class_name PowerPlantFactory
func generate_scene(_inventory):
	if not is_able_build(_inventory):
		return null
	print("Current Money: " + str(_inventory.get_money()))
	_inventory.change_money(-4000)
	print("Current Money: " + str(_inventory.get_money()))
	return generate_bought_scene()

func is_able_build(_inventory) -> bool:
	var purchase_amount = 4000
	if _inventory.get_money() >= purchase_amount:
		return true
	return false

func generate_bought_scene():
	var scene = load("res://scenes/buildings/power_plant.tscn")
	var power_plant = scene.instance()
	return power_plant
