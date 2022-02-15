class_name ToolInterfaces # Like a namespace, contains all the tool interfaces.

# ------------------------------------------------------------------------------
# Build tool interface.
class BuildTool:
	extends Node2D
	
	# --------------------------------------------------------------------------
	# Pure virtual, throws an error if called.
	func set_building_type(_type : int) -> void:
		assert(false)
	
	# --------------------------------------------------------------------------
	# Pure virtual, throws an error if called.
	func get_building_type() -> int:
		assert(false)
		return -1

	# --------------------------------------------------------------------------
	# Pure virtual, throws an error if called.
	func place_building(_tile_pos : Vector2) -> void:
		assert(false)
	
	# --------------------------------------------------------------------------
	# Pure virtual, throws an error if called.
	func request_place_building(_tile_pos: Vector2, _building_type: int, _id: int) -> void:
		assert(false)

# ------------------------------------------------------------------------------
# Buy tool interface.
class BuyTool:
	extends Node2D
	
	# --------------------------------------------------------------------------
	# Pure virtual, throws an error if called.
	func buy_tile(_tile_pos : Vector2) -> void:
		assert(false)
	
	# --------------------------------------------------------------------------
	# Pure virtual, throws an error if called.
	remote func request_buy(_tile_pos : Vector2, _id) -> void:
		assert(false)
		
	# --------------------------------------------------------------------------
	# Pure virtual, throws an error if called.
	remote func add_to_owner_dict(_tile_pos: Vector2, _id) -> void:
		assert(false)
	
	# --------------------------------------------------------------------------
	# Pure virtual, throws an error if called.	
	remote func sync_owner_tile_map(_tile_pos: Vector2, _outline_id) -> void:
		assert(false)
		
	# --------------------------------------------------------------------------
	# Pure virtual, throws an error if called.
	func check_availble(_tile_pos : Vector2) -> bool:
		assert(false)
		return false
