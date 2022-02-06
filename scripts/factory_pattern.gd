extends Node

var coal_plant_cost = 5

func create_coal_power_plant(resources: int, tile_reach: int) -> Node:
	if resources < coal_plant_cost:
		return null
	var power_plant = get_child(0).duplicate()
	power_plant.init(tile_reach)
	return power_plant

func resources_required_coal_power_plant() -> int:
	return coal_plant_cost
