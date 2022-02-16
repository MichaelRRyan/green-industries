extends "res://scripts/buildings/power_building.gd"

onready var colour = Color(255.0 / 255,165.0 / 255,0,125.0 / 255)
onready var centre: Vector2 = Vector2(0,0)
onready var display_energy_circle = false
onready var fuel_amount_display = $Label
onready var max_fuel_amount = 20
onready var current_fuel_amount = max_fuel_amount
const fuel_increase_amount = 10



func _ready():
	fuel_amount_display.text = str(current_fuel_amount)


func set_current_fuel_amount(amount : int) -> void:
	current_fuel_amount = amount if amount > 0 else current_fuel_amount


func _on_Timer_timeout():
	if current_fuel_amount > 0:
		current_fuel_amount -= 1
		fuel_amount_display.text = str(current_fuel_amount)
		if current_fuel_amount == 0:
			Utility.get_dependency("event_triggers", self, true).no_power()
			for building in powered_buildings:
				building.remove_from_power_sources(self)
			powered_buildings.clear()

func add_to_power_source():
	pass
	
	
func remove_from_power_source():
	pass

func is_powered() -> bool:
	return current_fuel_amount > 0


func _process(_delta):
	update()


func _draw():
	if display_energy_circle and current_fuel_amount > 0:
		draw_circle(centre, tile_radius * 110, colour)



remote func increase_fuel(is_caller: bool) -> void:
	if Network.is_online and is_caller:
		rpc("increase_fuel", false)
	if current_fuel_amount < max_fuel_amount:
		if current_fuel_amount == 0:
			for building in nearby_buildings:
				powered_buildings.append(building)
				building.add_to_power_sources(self)
				
		current_fuel_amount += fuel_increase_amount
		current_fuel_amount = clamp(current_fuel_amount, 0, max_fuel_amount)
		fuel_amount_display.text = str(current_fuel_amount)


func _on_PowerPlant_input_event(_viewport, event, shape_idx):
	if event.is_action_pressed("upgrade_factory") and shape_idx == 0:
		var collision_radius = $CollisionShape2D.shape.radius + 2
		var mouse_position = get_global_mouse_position()		
		if (mouse_position.x - position.x) * (mouse_position.x - position.x) + \
		(mouse_position.y - position.y) * (mouse_position.y - position.y) \
		< collision_radius * collision_radius:
			increase_fuel(true)


func _on_PowerPlant_mouse_entered():
	display_energy_circle = true
	z_index += 1


func _on_PowerPlant_mouse_exited():
	display_energy_circle = false
	z_index -= 1


