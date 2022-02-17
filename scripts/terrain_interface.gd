class_name TerrainInterfaces # Like a namespace, contains all the tool interfaces.

# ------------------------------------------------------------------------------
# terrain interface.
class BaseTerrain:
	extends Node2D
	
	# --------------------------------------------------------------------------
	# Pure virtual, throws an error if called.
	func is_tile_empty(_tile : Vector2) -> bool:
		assert(false)
		return false
	
	# --------------------------------------------------------------------------
	# Pure virtual, throws an error if called.	
	func get_tile_from_global_position(_pos : Vector2) -> Vector2:
		assert(false)
		return Vector2.ONE
	
	# --------------------------------------------------------------------------
	# Pure virtual, throws an error if called.	
	func get_global_position_from_tile(_tile : Vector2) -> Vector2:
		assert(false)
		return Vector2.ONE
	
	# --------------------------------------------------------------------------
	# Pure virtual, throws an error if called.	
	func set_cellv(_cell : Vector2, _type : int) -> void:
		assert(false)
		
	# --------------------------------------------------------------------------
	# Pure virtual, throws an error if called.
	func get_cellv(_cell : Vector2) -> int:
		assert(false)
		return -1
	
	# --------------------------------------------------------------------------
	# Pure virtual, throws an error if called.	
	func harvest_cell(_cell : Vector2) -> ResourceType:
		assert(false)
		return null
		
	# --------------------------------------------------------------------------
	# Pure virtual, throws an error if called.
	func on_click(_mouse_position: Vector2) -> void:
		assert(false)
	
	# --------------------------------------------------------------------------
	# Pure virtual, throws an error if called.	
	func get_tile_clicked(_position : Vector2) -> int:
		assert(false)
		return -1
