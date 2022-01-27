extends Area2D

var current_level = 0
var max_level = 10
onready var label : Label = $Label
onready var sprite : Sprite = $Sprite

export (Color, RGB) var mouse_over
export (Color, RGB) var mouse_out

func on_click():
	if current_level < max_level:
		current_level += 1
		label.text = str(current_level)
	if current_level == max_level:
		label.add_color_override("font_color", Color(1,0,0,1))

func _on_Factory_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("place_factory"):
		self.on_click()


func _on_Factory_mouse_entered():
	sprite.set_modulate(mouse_over)
	sprite.set_scale(Vector2(1.25,1.25))


func _on_Factory_mouse_exited():
	sprite.set_modulate(mouse_out)
	sprite.set_scale(Vector2(1.0,1.0))
