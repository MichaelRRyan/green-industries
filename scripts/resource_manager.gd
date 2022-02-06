extends Node

# An array of ResourceTypes.
var types : Array = []


# ------------------------------------------------------------------------------
# Doesn't do any bounds checks, can throw an error if not careful.
func get_resource_type(id : int) -> ResourceType:
	return types[id]


# ------------------------------------------------------------------------------
func get_resource_type_by_name(_name : String) -> ResourceType:
	for type in types:
		if type.name == _name:
			return type
	return null


# ------------------------------------------------------------------------------
# Creates a new resource with the given values and returns the id.
func add_resource_type(_name : String, recipe : ResourceType.Recipe = null) -> int:
	var resource = ResourceType.new()
	resource.name = _name
	resource.recipe = recipe
	resource.id = types.size() # The position of the new resource in the array.
	types.append(resource)
	return resource.id


# ------------------------------------------------------------------------------
func _ready() -> void:
	# These creations will later be moved to an external json file.
	var _v # A variable to discard the return value without warnings.
	_v = add_resource_type("wood") # Creates a 'wood' resource type.
	_v = add_resource_type("minerals") # Creates a 'minerals' resource type.


# ------------------------------------------------------------------------------
