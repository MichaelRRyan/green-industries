extends "res://scripts/classes/abstract_factory_pattern.gd"


class_name MineralsHarvesterFactory
func generate_scene(_inventory):
	var purchase_amount = 1000
	if not is_able_build(_inventory):
		return null

	_inventory.change_money(-purchase_amount)

	return generate_bought_scene()

func is_able_build(_inventory) -> bool:
	var purchase_amount = 1000
	if _inventory.get_money() >= purchase_amount:
		return true
	return false

func generate_bought_scene():
	var scene = load("res://scenes/buildings/mine.tscn")
	var harvester = scene.instance()
	return harvester
