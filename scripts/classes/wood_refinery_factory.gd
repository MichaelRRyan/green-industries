extends "res://scripts/classes/abstract_factory_pattern.gd"

class_name WoodRefineryFactory
func generate_scene():
	var scene = load("res://scenes/buildings/refinery.tscn")
	var refinery = scene.instance()
	var resource_manager = Utility.get_dependency("resource_manager")
	var output_material = resource_manager.get_resource_type_by_name("lumber")
	refinery.set_output_material(output_material)
	return refinery
