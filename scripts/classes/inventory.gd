extends Node
class_name Inventory

signal money_changed(amount)
signal resource_changed(type, quantity)


var _money : int = 0
var _resources : Dictionary = { }

# Variables for syncing.
const _LOCAL_PEER_ID = 1
var _peer_id = 1
var _resource_manager = null


# ------------------------------------------------------------------------------
func set_peer_id(peer_id : int) -> void:
	_peer_id = peer_id

# ------------------------------------------------------------------------------
func get_money() -> int:
	return _money
	

# ------------------------------------------------------------------------------
remote func set_money(new_amount : int) -> void:
	_money = new_amount
		
	# Syncs if this is not a local inventory.
	if _peer_id > 10:
		rpc_id(_peer_id, "set_money", new_amount)
	else:
		emit_signal("money_changed", _money)


# ------------------------------------------------------------------------------
func change_money(change_amount : int) -> void:
	_money += change_amount
	
	# Syncs if this is not a local inventory.
	if _peer_id > 10:
		rpc_id(_peer_id, "set_money", _money)
	else:
		emit_signal("money_changed", _money)


# ------------------------------------------------------------------------------
func get_quantity(resource : ResourceType) -> int:
	if _resources.has(resource):
		return _resources[resource]
	return 0


# ------------------------------------------------------------------------------
# Adds the quantity of resources of the type passed. If the quantity is zero or
#	below the method has no effect.
func add_resources(resource : ResourceType, quantity : int) -> void:
	if quantity <= 0:
		return
		
	if _resources.has(resource):
		_resources[resource] += quantity
	else:
		_resources[resource] = quantity
	
	# Syncs if this is not a local inventory.
	if _peer_id > 10:
		rpc_id(_peer_id, "remotely_set_resource", resource.name, _resources[resource])
	else:
		emit_signal("resource_changed", resource, _resources[resource])
	
	
# ------------------------------------------------------------------------------
# Tries to remove a quantity of a given resource. Fails if the resource does not
#	exist in the inventory or if there's less of the resource than argument 
#	'quantity'. Returns true if successful, false if not.
# Also returns false if the quantity is 0 or less.
func remove_resources(resource : ResourceType, quantity : int) -> bool:
	if quantity <= 0:
		return false
	
	if _resources.has(resource) and _resources[resource] >= quantity:
		_resources[resource] -= quantity
		
		# Syncs if this is not a local inventory.
		if _peer_id > 10:
			rpc_id(_peer_id, "remotely_set_resource", resource.name, _resources[resource])
		else:
			emit_signal("resource_changed", resource, _resources[resource])
		
		return true
	return false

	
# ------------------------------------------------------------------------------
remote func remotely_set_resource(resource_name : String, quantity : int) -> void:
	var resource = _resource_manager.get_resource_type_by_name(resource_name)
	_resources[resource] = quantity
	emit_signal("resource_changed", resource, quantity)


# ------------------------------------------------------------------------------
func clear() -> void:
	# If a local player.
	if _peer_id == _LOCAL_PEER_ID:
		
		# Sends signals for all the nullified resources and money.
		emit_signal("money_changed", 0)
		for resource in _resources.keys():
			emit_signal("resource_changed", resource, 0)
	
	_money = 0
	_resources = { }
	
	

	
# ------------------------------------------------------------------------------
func _ready():
	var managers = get_tree().get_nodes_in_group("resource_manager")
	if managers and not managers.empty():
		_resource_manager = managers[0]
	_money = 30000
	
	
# ------------------------------------------------------------------------------
func _process(_delta):
	#GetGameStat.stats = get_money()
	GetGameStat.money(get_money())
