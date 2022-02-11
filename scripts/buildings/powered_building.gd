extends Area2D

var power_sources = 0 

func _ready():
	get_node("CollisionShape2D").shape = get_node("CollisionShape2D").shape.duplicate()


func add_to_power_sources(_source):
	power_sources += 1
	
	
func remove_from_power_sources(_source):
	power_sources -= 1


func is_powered() -> bool:
	return power_sources > 0
