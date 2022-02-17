extends Area2D

onready var _pollution_manager = Utility.get_dependency("pollution_manager", self, true)

var power_sources = 0 
var _tile_position = Vector2.ZERO
var _terrain = null

func _ready():
	_terrain = Utility.get_dependency("terrain", self, true)
	get_node("CollisionShape2D").shape = get_node("CollisionShape2D").shape.duplicate()
	if _terrain and (not Network.is_online or Network.state == Network.State.HOSTING):
		_tile_position = _terrain.get_tile_from_global_position(global_position)
	var bulldoze_tool = Utility.get_dependency("bulldoze_tool")
	bulldoze_tool.connect("building_destroyed", self, "destroy_building")

func destroy_building(tile_pos : Vector2) -> void:
	if _tile_position == tile_pos:
		queue_free()
	
func add_to_power_sources(_source):
	power_sources += 1
	
	
func remove_from_power_sources(_source):
	power_sources -= 1


func is_powered() -> bool:
	return power_sources > 0


func _process(delta):
	if is_powered():
		_pollution_manager.increase_pollution(delta, position)
