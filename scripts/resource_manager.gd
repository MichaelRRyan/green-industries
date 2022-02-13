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
func add_resource_type(_name : String, texture_region : Rect2,
					   recipe : ResourceType.Recipe = null) -> int:
			
	var resource = ResourceType.new()
	resource.name = _name
	resource.texture_region = texture_region
	resource.recipe = recipe
	resource.id = types.size() # The position of the new resource in the array.
	types.append(resource)
	return resource.id


# ------------------------------------------------------------------------------
func _ready() -> void:
	# These creations will later be moved to an external json file.
	var _v # A variable to discard the return value without warnings.
	_v = add_resource_type("wood", Rect2(0, 0, 128, 128)) # Creates a 'wood' resource type.
	_v = add_resource_type("minerals", Rect2(128, 0, 128, 128)) # Creates a 'minerals' resource type.
	var lumber_recipe = ResourceType.Recipe.new()
	var wood_ingredient = ResourceType.Ingredient.new()
	wood_ingredient.resource_id = get_resource_type_by_name("wood").id
	wood_ingredient.quantity = 1
	lumber_recipe.ingredients.append(wood_ingredient)
	_v = add_resource_type("lumber", Rect2(0, 0, 128, 128), lumber_recipe)
	var metal_recipe = ResourceType.Recipe.new()
	var minerals_ingredient = ResourceType.Ingredient.new()
	minerals_ingredient.resource_id = get_resource_type_by_name("minerals").id
	minerals_ingredient.quantity = 1
	metal_recipe.ingredients.append(minerals_ingredient)
	_v = add_resource_type("metal", Rect2(128, 0, 128, 128), metal_recipe)

# ------------------------------------------------------------------------------
