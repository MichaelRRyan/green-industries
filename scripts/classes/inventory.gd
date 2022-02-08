class_name Inventory

var _money : float = 0
var _resources : Dictionary = { }


# ------------------------------------------------------------------------------
func get_money() -> float:
	return _money
	

# ------------------------------------------------------------------------------
func set_money(new_amount : float) -> void:
	_money = new_amount


# ------------------------------------------------------------------------------
func change_money(change_amount : float) -> void:
	_money += change_amount


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
		return true
	return false
	
	
# ------------------------------------------------------------------------------
func clear() -> void:
	_money = 0
	_resources = { }

	
# ------------------------------------------------------------------------------
