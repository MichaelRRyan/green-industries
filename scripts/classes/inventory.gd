extends Node
class_name Inventory

var _money : float = 0
var _resources : Dictionary = { }

# Variables for syncing.
var _peer_id = 1
var _resource_manager = null


# ------------------------------------------------------------------------------
func set_peer_id(peer_id : int) -> void:
	_peer_id = peer_id


# ------------------------------------------------------------------------------
func get_money() -> float:
	return _money
	

# ------------------------------------------------------------------------------
remote func set_money(new_amount : float) -> void:
	_money = new_amount
		
	# Syncs if this is not a local inventory.
	if _peer_id != 1:
		rpc_id(_peer_id, "set_money", new_amount)


# ------------------------------------------------------------------------------
func change_money(change_amount : float) -> void:
	_money += change_amount
	
	# Syncs if this is not a local inventory.
	if _peer_id != 1:
		rpc_id(_peer_id, "set_money", _money)


# ------------------------------------------------------------------------------
func get_quantity(resource : ResourceType) -> int:
	if _resources.has(resource):
		return _resources[resource]
	return 0


# ------------------------------------------------------------------------------
# Adds the quantity of resources of the type passed. If the quantity is zero or
#	below the method has no effect.
remote func add_resources(resource : ResourceType, quantity : int) -> void:
	if quantity <= 0:
		return
		
	if _resources.has(resource):
		_resources[resource] += quantity
	else:
		_resources[resource] = quantity
	
	# Syncs if this is not a local inventory.
	if _peer_id != 1:
		rpc_id(_peer_id, "remotely_set_resource", resource.name, _resources[resource])
	
	
# ------------------------------------------------------------------------------
# Tries to remove a quantity of a given resource. Fails if the resource does not
#	exist in the inventory or if there's less of the resource than argument 
#	'quantity'. Returns true if successful, false if not.
# Also returns false if the quantity is 0 or less.
remote func remove_resources(resource : ResourceType, quantity : int) -> bool:
	if quantity <= 0:
		return false
	
	if _resources.has(resource) and _resources[resource] >= quantity:
		_resources[resource] -= quantity
		
		# Syncs if this is not a local inventory.
		if _peer_id != 1:
			rpc_id(_peer_id, "remotely_set_resource", resource.name, _resources[resource])
		
		return true
	return false

	
# ------------------------------------------------------------------------------
remote func remotely_set_resource(resource_name : String, quantity : int) -> void:
	var resource = _resource_manager.get_resource_type_by_name(resource_name)
	_resources[resource] = quantity


# ------------------------------------------------------------------------------
func clear() -> void:
	_money = 0
	_resources = { }

	
# ------------------------------------------------------------------------------
func _ready():
	var managers = get_tree().get_nodes_in_group("resource_manager")
	if managers and not managers.empty():
		_resource_manager = managers[0]

	
# ------------------------------------------------------------------------------
