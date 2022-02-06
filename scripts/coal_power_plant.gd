extends Area2D

onready var colour = Color(255.0 / 255,165.0 / 255,0,125.0 / 255)
onready var centre: Vector2 = Vector2(0,0)
var num_tiles = 3
var radius = 110 * num_tiles
onready var display_energy_circle = false
onready var powerRadius = $PowerRadius
onready var list_of_powered_objects = []
onready var fuel_amount_display = $Label
onready var max_fuel_amount = 20
onready var current_fuel_amount = max_fuel_amount
const fuel_increase_amount = 10
onready var collision_shape = $CollisionShape2D
onready var _timer = null

func _ready():
	_timer = Timer.new()
	add_child(_timer)
	_timer.connect("timeout", self, "_on_Timer_timeout")
	_timer.set_wait_time(1.0)
	_timer.set_one_shot(false)
	_timer.start()
	powerRadius.shape.radius = radius
	fuel_amount_display.text = str(current_fuel_amount)

func _on_Timer_timeout():
	if current_fuel_amount > 0:
		current_fuel_amount -= 1
		fuel_amount_display.text = str(current_fuel_amount)
		if current_fuel_amount == 0:
			for item in list_of_powered_objects:
				item.decrease_amount_of_power_plants()

func init(number_of_tiles: int):
	num_tiles = number_of_tiles
	radius = 110 * num_tiles

func _process(_delta):
	update()

func _draw():
	if display_energy_circle and current_fuel_amount > 0:
		draw_circle(centre, radius, colour)

func _on_CoalPowerPlant_mouse_entered():
	display_energy_circle = true
	z_index += 1

func _on_CoalPowerPlant_mouse_exited():
	display_energy_circle = false
	z_index -= 1

func _on_CoalPowerPlant_area_shape_entered(_area_rid, area, _area_shape_index, _local_shape_index):
	area.increase_amount_of_power_plants()
	list_of_powered_objects.push_back(area)

func _on_CoalPowerPlant_area_shape_exited(_area_rid, area, _area_shape_index, _local_shape_index):
	area.decrease_amount_of_power_plants()
	list_of_powered_objects.erase(area)

func _on_CoalPowerPlant_input_event(_viewport, event, shape_idx):
	if event.is_action_pressed("upgrade_factory") and shape_idx == 0:
		var collision_radius = collision_shape.shape.radius + 2
		var mouse_position = get_global_mouse_position()		
		if (mouse_position.x - position.x) * (mouse_position.x - position.x) + \
		(mouse_position.y - position.y) * (mouse_position.y - position.y) \
		< collision_radius * collision_radius:
			if current_fuel_amount < max_fuel_amount:
				if current_fuel_amount == 0:
					for item in list_of_powered_objects:
						item.increase_amount_of_power_plants()
				current_fuel_amount += fuel_increase_amount
				current_fuel_amount = clamp(current_fuel_amount, 0, max_fuel_amount)
				fuel_amount_display.text = str(current_fuel_amount)
