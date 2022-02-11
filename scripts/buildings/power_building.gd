extends "res://scripts/buildings/powered_building.gd"
tool

export var tile_radius : float = 0 setget set_radius, get_radius

var nearby_buildings = []

var power_sources_buildings = []
var powered_buildings = []
var power_roots = {}

# ------------------------------------------------------------------------------
func _on_PowerBuilding_area_entered(area):
	nearby_buildings.push_back(area)
	
	if is_powered() and not is_a_power_source(area):
		powered_buildings.append(area)
		area.add_to_power_sources(self)


# ------------------------------------------------------------------------------
func _on_PowerBuilding_area_exited(area):
	nearby_buildings.erase(area)
	
	if power_sources_buildings.has(area):
		power_sources_buildings.erase(area)
		
	elif powered_buildings.has(area):
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
	
	for source in power_sources_buildings:
		if building == source or source.is_a_power_source(building):
			return true
			
	return false


func get_power_root():
	if is_powered() and power_roots.size() == 0:
		return self
	elif not power_roots.empty():
		return power_roots.keys().front()
#	elif power_sources_buildings.size() > 0:
#		return power_sources_buildings.front().get_power_root()
#	return null
	

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


func is_powered() -> bool:
	return not power_roots.empty()
