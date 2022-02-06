extends Camera2D

var movement_speed = 750
var velocity = Vector2.ZERO
var input = Vector2.ZERO
var zoom_amount = Vector2( 0.25, 0.25 )
var events = {}

var left
var top
var right
var bottom
var mouse_move_border = 50

func _ready():
	_set_bounds()


func _process(delta):
	
	if Input.is_action_pressed("camera_left"):
		move_left()
	if Input.is_action_pressed("camera_right"):
		move_right()
	
	if Input.is_action_pressed("camera_up"):
		move_up()
	if Input.is_action_pressed("camera_down"):
		move_down()
	
	if Input.is_action_pressed("camera_zoom_in") or Input.is_action_just_released("camera_zoom_in"):
		zoom_in()
	if Input.is_action_pressed("camera_zoom_out") or Input.is_action_just_released("camera_zoom_out"):
		zoom_out() 
	
	var mouse_pos = get_viewport().get_mouse_position()
	
	if mouse_pos.x < mouse_move_border:
		move_left()
	if mouse_pos.x > get_viewport().size.x - mouse_move_border:
		move_right()
	
	if mouse_pos.y < mouse_move_border:
		move_up()
	if mouse_pos.y > get_viewport().size.y - mouse_move_border:
		move_down()
	
	position += input.normalized() * zoom * movement_speed * delta
	
	position.x = clamp(position.x, left, right)
	position.y = clamp(position.y, top, bottom)
	
	input = Vector2.ZERO


func _input(event):
	if event is InputEventScreenDrag:
		var i_event:InputEventScreenDrag = event
		var i_vec = i_event.get_relative().normalized()
		if i_vec.x > 0:
			move_right()
		if i_vec.x < 0:
			move_left()
		if i_vec.y < 0:
			move_up()
		if i_vec.y > 0:
			move_down()
		
	if event is InputEventScreenTouch:
		if event.pressed:
			events[event.index] = event
		else:
			events.erase(event.index)
		if events.size() == 2:
			var drag_distance = events[0].position.distance_to(events[1].position)
			if drag_distance  > 1:
				zoom_out()
			if drag_distance < 1:
				zoom_in()
	
	
func move_left():
	input.x -= 1.0


func move_right():
	input.x += 1.0


func move_up():
	input.y -= 1.0


func move_down():
	input.y += 1.0


func zoom_in():
	if zoom >= Vector2(1.5, 1.5):
		zoom -= zoom_amount
		_set_bounds()


func zoom_out():
	if zoom < Vector2(4.5, 4.5):
		zoom += zoom_amount
		_set_bounds()


func _set_bounds():
	left = limit_left + get_viewport().size.x / 2.0 * zoom.x
	top = limit_top + get_viewport().size.y / 2.0 * zoom.y
	right = limit_right - get_viewport().size.x / 2.0 * zoom.x
	bottom = limit_bottom - get_viewport().size.y / 2.0 * zoom.y
