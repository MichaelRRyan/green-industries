class_name ResourceType


#-------------------------------------------------------------------------------
# Sub classes within ResourceType.
#-------------------------------------------------------------------------------
class Recipe:
	var ingredients : Array = [] # An array of Ingredients. 

class Ingredient:
	var resource_id : int = -1
	var quantity : int = 1


#-------------------------------------------------------------------------------
# ResourceType's members.
#-------------------------------------------------------------------------------
var name : String = "blank_resource"
var texture_region : Rect2
var id : int = -1
var recipe : Recipe = null
