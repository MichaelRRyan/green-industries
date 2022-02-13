extends "res://scripts/classes/abstract_factory_pattern.gd"

class_name MineralsRefineryFactory
func generate_scene():
	var scene = load("res://scenes/buildings/refinery.tscn")
	var refinery = scene.instance()
	var resource_manager = Utility.get_dependency("resource_manager")
	var output_material = resource_manager.get_resource_type_by_name("metal")
	refinery.set_output_material(output_material)
	return refinery
