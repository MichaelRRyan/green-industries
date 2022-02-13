#extends Node
#
#var wood_refinery = preload("res://scenes/buildings/refinery.tscn")
#var minerals_refinery = preload("res://scenes/buildings/refinery.tscn")
#
#func generate_wood_refinery():
#	var return_building = wood_refinery.instance()
#	var resource_manager = Utility.get_dependency("resource_manager", self, true)
#	var output_material = resource_manager.get_resource_type_by_name("lumber")
#	return_building.set_output_material(output_material)
#	return return_building
#
#func generate_mineral_refinery():
#	var return_building = minerals_refinery.instance()
#	var resource_manager = Utility.get_dependency("resource_manager", self, true)
#	var metal = resource_manager.get_resource_type_by_name("metal")
#	return_building.set_output_material(metal)
#	return return_building
class_name AbstractFactory
func generate_scene():
	pass
