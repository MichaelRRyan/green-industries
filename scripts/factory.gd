extends "res://scripts/buildings/powered_building.gd"

var current_level = 1
var max_level = 10
onready var has_power_text : Label = $HasPower
onready var factory_type : Label = $Label
onready var respond_to_input = false
onready var timer = Timer.new()
onready var number_of_power_plants = 0
export (Color, RGB) var mouse_over
export (Color, RGB) var mouse_out
var input_material_amount : int = 0
var input_material_id : int = -1
var inventory = null
var resource_manager = null
var resulting_money = 0


func _ready():
	timer.connect("timeout", self, "_on_timer_timeout")
	add_child(timer)
	timer.start()
	has_power_text.visible = false
	resource_manager = Utility.get_dependency("resource_manager", self, true)


func _on_timer_timeout():
	respond_to_input = true
	timer.queue_free()


func on_click():
	var num_ingredient = inventory.get_quantity(\
		resource_manager.get_resource_type(input_material_id))
	if num_ingredient > 0:
		input_material_amount += 1
		inventory.remove_resources(resource_manager.get_resource_type(input_material_id), 1)


func _on_Factory_input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed("upgrade_factory") and respond_to_input:
		self.on_click()
			
			
func _on_Factory_mouse_entered():
	has_power_text.text = "powered" if is_powered() else "unpowered"
	has_power_text.visible = true


func _on_Factory_mouse_exited():
	has_power_text.visible = false
	

func set_inventory(_inventory) -> void:
	inventory = _inventory
	
	
func set_input_material(_input_id) -> void:
	input_material_id = _input_id
	call_deferred("set_text")
	
	
func set_text() -> void:
	factory_type.text = resource_manager.get_resource_type(input_material_id).name
	
	
func set_output_money_amount(output_amount : int) -> void:
	resulting_money = output_amount


func _on_CreateMoneyTimer_timeout():
	if is_powered() and input_material_amount > 0:
		input_material_amount -= 1
		inventory.change_money(resulting_money)
