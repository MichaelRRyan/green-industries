extends "res://scripts/buildings/powered_building.gd"
tool

export var tile_radius : float = 0 setget set_radius, get_radius

var nearby_buildings = []

var powered_buildings = []
var power_roots = {}

onready var can_add_fuel = true

# ------------------------------------------------------------------------------
func _on_PowerBuilding_area_entered(area):
	nearby_buildings.push_back(area)
	
	if is_powered() and not is_a_power_source(area):
		powered_buildings.append(area)
		area.add_to_power_sources(self)


# ------------------------------------------------------------------------------
func _on_PowerBuilding_area_exited(area):
	nearby_buildings.erase(area)
		
	if powered_buildings.has(area):
		powered_buildings.erase(area)


# ------------------------------------------------------------------------------
func add_to_power_sources(source):
	var just_gained_power = power_roots.empty()
	
	if not is_a_power_source(source):
		var root = source.get_power_root()
		if power_roots.has(root):
			power_roots[root].append(source)
		else:
			power_roots[root] = [source]
	
	if just_gained_power:
		for building in nearby_buildings:
			if not is_a_power_source(building):
				powered_buildings.append(building)
				building.add_to_power_sources(self)


# ------------------------------------------------------------------------------
func remove_from_power_sources(source):
	var list = []
	for root in power_roots.keys():
		if power_roots[root].has(source):
			power_roots[root].erase(source)
			if power_roots[root].empty():
				list.append(root)
				
	for item in list:
		power_roots.erase(item)
	
	if power_roots.empty():
		for building in powered_buildings:
			building.remove_from_power_sources(self)
		powered_buildings.clear()


# ------------------------------------------------------------------------------
func is_a_power_source(building) -> bool:
	for root in power_roots:
		for source in power_roots[root]:
			if building == source or source.is_a_power_source(building):
				return true
				
	return false


func get_power_root():
	if is_powered() and power_roots.size() == 0:
		return self
	elif not power_roots.empty():
		return power_roots.keys().front()
	

# ------------------------------------------------------------------------------
func set_radius(value : float) -> void:
	tile_radius = value
	if Engine.editor_hint:
		get_node("CollisionShape2D").shape.radius = tile_radius * 110


# ------------------------------------------------------------------------------
func get_radius() -> float:
	return tile_radius


func _ready():
	get_node("CollisionShape2D").shape.radius = tile_radius * 110


func destroy_building(tile_pos : Vector2) -> void:
	if _tile_position == tile_pos:
		can_add_fuel = false
		Utility.get_dependency("event_triggers", self, true).no_power()
		for building in powered_buildings:
			building.remove_from_power_sources(self)
		powered_buildings.clear()
		queue_free()


func is_powered() -> bool:
	return not power_roots.empty()
