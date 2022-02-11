extends "res://scripts/buildings/powered_building.gd"

var current_level = 1
var max_level = 10
onready var label : Label = $Label
onready var sprite : Sprite = $Sprite
onready var has_power_text : Label = $HasPower
onready var respond_to_input = false
onready var timer = Timer.new()
onready var number_of_power_plants = 0
export (Color, RGB) var mouse_over
export (Color, RGB) var mouse_out

func _ready():
	timer.connect("timeout", self, "_on_timer_timeout")
	add_child(timer)
	timer.start()
	label.text = str(current_level)
	has_power_text.visible = false

func _on_timer_timeout():
	respond_to_input = true
	timer.queue_free()

func increase_amount_of_power_plants():
	print("Increase number of plants for factory: " + str(get_rid()))
	number_of_power_plants += 1
	
func decrease_amount_of_power_plants():
	if number_of_power_plants > 0:
		number_of_power_plants -= 1
	print("Decrease number of plants for: " + str(get_rid()))
	print(str(number_of_power_plants) + " number of power plants left for factory")
	
func has_power() -> bool:
	return number_of_power_plants > 0

remote func on_click(is_caller: bool):
	if Network.is_online and is_caller:
		rpc("on_click", false)
	if current_level < max_level:
		current_level += 1
		label.text = str(current_level)
	if current_level == max_level:
		label.add_color_override("font_color", Color(1,0,0,1))

func _on_Factory_input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed("upgrade_factory") and respond_to_input:
		self.on_click(true)

func _process(delta):
	 if has_power_text.text == "powered":
			Pollution.carbon += 0.01 * delta
			Pollution.set_carbon(Pollution.carbon)
			
			
func _on_Factory_mouse_entered():
	sprite.set_modulate(mouse_over)
	sprite.set_scale(Vector2(1.25,1.25))
	z_index += 1
	has_power_text.text = "powered" if is_powered() else "unpowered"
	has_power_text.visible = true


func _on_Factory_mouse_exited():
	sprite.set_modulate(mouse_out)
	sprite.set_scale(Vector2(1.0,1.0))
	z_index -= 1
	has_power_text.visible = false
