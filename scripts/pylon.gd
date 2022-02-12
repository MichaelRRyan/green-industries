extends "res://scripts/buildings/power_building.gd"

const BLUE : Color = Color(0,0,1,0.4)
const RED : Color = Color(1,0,0,0.4)
const GREEN : Color = Color(0,1,0,0.4)
onready var colour = RED
onready var centre: Vector2 = Vector2(0,0)
onready var display_energy_circle = false


func _process(_delta):
	update()
	if is_powered():
		colour = GREEN
	elif power_roots.size() > 0:
		colour = BLUE
	else:
		colour = RED


func _draw():
	if display_energy_circle:
		draw_circle(centre, get_radius() * 110, colour)


func _on_Pylon_mouse_entered():
	display_energy_circle = true


func _on_Pylon_mouse_exited():
	display_energy_circle = false
	
func _ready():
	#name = str(Network.pylons)
	add_to_group("pylons")
	Network.pylons += 1
	print(Network.pylons)
