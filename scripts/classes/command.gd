class_name Commands # Like a namespace, contains all the commands.

# ------------------------------------------------------------------------------
# ABSTRACT COMMANDS
# ------------------------------------------------------------------------------
class AbstractCommand:
	# Pure virtual, throws an error if called.
	func execute() -> void:
		assert(false)



# ------------------------------------------------------------------------------
# Abstract build command.
class BuildCommand:
	extends AbstractCommand
	
	var _build_tool = Utility.get_dependency("build_tool")
	
	
	# --------------------------------------------------------------------------
	# Pure virtual, throws an error if called.
	func setup(_tile_pos : Vector2, _building_type : int, _owner_id : int = 1) -> void:
		assert(false)
	
	# --------------------------------------------------------------------------
	# Pure virtual, throws an error if called.
	func execute() -> void:
		assert(false)


# ------------------------------------------------------------------------------
# Abstract buy land command.
class BuyLandCommand:
	extends AbstractCommand
	
	var _buy_tool = Utility.get_dependency("buy_tool")
	
	
	# --------------------------------------------------------------------------
	# Pure virtual, throws an error if called.
	func setup(_tile_pos : Vector2, _owner_id : int = 1) -> void:
		assert(false)
	
	# --------------------------------------------------------------------------
	# Pure virtual, throws an error if called.
	func execute() -> void:
		assert(false)

class BuyCommand:
	extends AbstractCommand
	var _shop = Utility.get_dependency("resource_shop")
	
	
	func setup(_resource , _amount,_owner_id : int = 1) -> void:
		assert(false)
		
	# Pure virtual, throws an error if called.
	func execute() -> void:
		assert(false)
		
class SellCommand:
	extends AbstractCommand
	var _shop = Utility.get_dependency("resource_shop")
	
	
	func setup(_resource , _amount,_owner_id : int = 1) -> void:
		assert(false)
		
	# Pure virtual, throws an error if called.
	func execute() -> void:
		assert(false)

class BullDozeCommand:
	extends AbstractCommand
	
	var _bulldoze_tool = Utility.get_dependency("bulldoze_tool")
	
	func setup(_tile_pos : Vector2, _owner_id : int = 1) -> void:
		assert(false)
		
	func execute() -> void:
		assert(false)
# ------------------------------------------------------------------------------
# CONCRETE COMMANDS
# ------------------------------------------------------------------------------
# Used for offline games.
class OfflineBuildCommand:
	extends BuildCommand
	
	var _tile_pos = Vector2.ZERO
	var _building_type = Tile.Type.NONE
	var _owner_id = 1 # Defaults to local player (1).
	
	
	# --------------------------------------------------------------------------
	func setup(tile_pos : Vector2, building_type : int,  owner_id : int = 1) -> void:
		_tile_pos = tile_pos
		_building_type = building_type
		_owner_id = owner_id
	
	
	# --------------------------------------------------------------------------
	func execute() -> void:
		_build_tool.place_building(_tile_pos, _owner_id, _building_type)
	# --------------------------------------------------------------------------
	

	

# Used for offline games.
class OfflineBuyLandCommand:
	extends BuyLandCommand
	
	var _tile_pos = Vector2.ZERO
	var _owner_id = 1 # Defaults to local player (1).
	
	# --------------------------------------------------------------------------
	func setup(tile_pos : Vector2, owner_id : int = 1) -> void:
		_tile_pos = tile_pos
		_owner_id = owner_id
	
	
	# --------------------------------------------------------------------------
	func execute() -> void:
		_buy_tool.buy_tile(_tile_pos, _owner_id)

class OfflineBuyCommand:
	extends BuyCommand
	
	var _resource = null 
	var _amount = 0
	var _owner_id = 1
	
	func setup(resource , amount,owner_id : int = 1) -> void:
		_resource = resource
		_amount = amount
		_owner_id = owner_id
	
		
	func execute() -> void:
		_shop.buy(_resource,_amount,_owner_id)


class OfflineSellCommand:
	extends SellCommand
	
	var _resource = null 
	var _amount = 0
	var _owner_id = 1
	
	func setup(resource , amount,owner_id : int = 1) -> void:
		_resource = resource
		_amount = amount
		_owner_id = owner_id
		
	
	func execute() -> void:
		_shop.sell(_resource,_amount,_owner_id)
		

class OfflineBullDozeCommand:
	extends BullDozeCommand
	
	var _tile_pos = Vector2.ZERO
	var _owner_id = 1 # Defaults to local player (1).
	
	# --------------------------------------------------------------------------
	func setup(tile_pos : Vector2, owner_id : int = 1) -> void:
		_tile_pos = tile_pos
		_owner_id = owner_id
	
	
	# --------------------------------------------------------------------------
	func execute() -> void:
		_bulldoze_tool.bulldose_tile(_tile_pos, _owner_id)
# ------------------------------------------------------------------------------


# Used for hosted games.
class HostBuildCommand:
	extends BuildCommand
	
	var _tile_pos = Vector2.ZERO
	var _building_type = Tile.Type.NONE
	var _owner_id = 1 # Defaults to local player (1).
	
	
	# --------------------------------------------------------------------------
	func setup(tile_pos : Vector2, building_type : int,  owner_id : int = 1) -> void:
		_tile_pos = tile_pos
		_building_type = building_type
		_owner_id = owner_id
	
	
	# --------------------------------------------------------------------------
	func execute() -> void:
		_build_tool.place_building(_tile_pos, _owner_id, _building_type)


# ------------------------------------------------------------------------------
# Used for hosted games.
class HostBuyLandCommand:
	extends BuyLandCommand
	
	var _tile_pos = Vector2.ZERO
	var _owner_id = 1 # Defaults to local player (1).
	
	# --------------------------------------------------------------------------
	func setup(tile_pos : Vector2, owner_id : int = 1) -> void:
		_tile_pos = tile_pos
		_owner_id = owner_id
	
	
	# --------------------------------------------------------------------------
	func execute() -> void:
		_buy_tool.buy_tile(_tile_pos, _owner_id)


#----------------------------------------------------------------------
class HostBuyCommand:
	extends BuyCommand
	
	var _resource = null 
	var _amount = 0
	var _owner_id = 1
	
	func setup(resource , amount,owner_id : int = 1) -> void:
		_resource = resource
		_amount = amount
		_owner_id = owner_id
	
		
	func execute() -> void:
		_shop.buy(_resource,_amount,_owner_id)

# ------------------------------------------------------------------------------
class HostSellCommand:
	extends SellCommand
	
	var _resource = null 
	var _amount = 0
	var _owner_id = 1
	
	func setup(resource , amount,owner_id : int = 1) -> void:
		_resource = resource
		_amount = amount
		_owner_id = owner_id
		
	
	func execute() -> void:
		_shop.sell(_resource,_amount,_owner_id)

class HostBullDozeCommand:
	extends BullDozeCommand
	
	var _tile_pos = Vector2.ZERO
	var _owner_id = 1 # Defaults to local player (1).
	
	# --------------------------------------------------------------------------
	func setup(tile_pos : Vector2, owner_id : int = 1) -> void:
		_tile_pos = tile_pos
		_owner_id = owner_id
	
	
	# --------------------------------------------------------------------------
	func execute() -> void:
		_bulldoze_tool.bulldose_tile(_tile_pos, _owner_id)
# ------------------------------------------------------------------------------
# Used for multiplayer games as the client.
class ClientBuildCommand:
	extends BuildCommand
	
	var _tile_pos = Vector2.ZERO
	var _building_type = Tile.Type.NONE
	
	
	# --------------------------------------------------------------------------
	func setup(tile_pos : Vector2, building_type : int,  _unused_id : int = -1) -> void:
		_tile_pos = tile_pos
		_building_type = building_type
	
	
	# --------------------------------------------------------------------------
	func execute() -> void:
		_build_tool.rpc_id(1, "request_place_building", _tile_pos, \
			_build_tool.get_building_type())


# ------------------------------------------------------------------------------
# Used for multiplayer games as the client.
class ClientBuyLandCommand:
	extends BuyLandCommand
	
	var _tile_pos = Vector2.ZERO
	
	# --------------------------------------------------------------------------
	func setup(tile_pos : Vector2, _unused_id : int = -1) -> void:
		_tile_pos = tile_pos
	
	
	# --------------------------------------------------------------------------
	func execute() -> void:
		_buy_tool.rpc_id(1, "request_buy", _tile_pos)
# ------------------------------------------------------------------------------
class ClientBuyCommand:
	extends BuyCommand
	
	var _resource = null 
	var _amount = 0
	var _owner_id = 1
	
	func setup(resource , amount,owner_id : int = 1) -> void:
		_resource = resource
		_amount = amount
		_owner_id = owner_id
	
		
	func execute() -> void:
		_shop.buy(_resource,_amount,_owner_id)
# ------------------------------------------------------------------------------
class ClientSellCommand:
	extends SellCommand
	
	var _resource = null 
	var _amount = 0
	var _owner_id = 1
	
	func setup(resource , amount,owner_id : int = 1) -> void:
		_resource = resource
		_amount = amount
		_owner_id = owner_id
		
	
	func execute() -> void:
		_shop.sell(_resource,_amount,_owner_id)


class ClientBullDozeComand:
	extends BullDozeCommand
	var _tile_pos = Vector2.ZERO
	
	# --------------------------------------------------------------------------
	func setup(tile_pos : Vector2, _unused_id : int = -1) -> void:
		_tile_pos = tile_pos
	
	
	# --------------------------------------------------------------------------
	func execute() -> void:
		_bulldoze_tool.rpc_id(1, "request_bulldoze", _tile_pos)
