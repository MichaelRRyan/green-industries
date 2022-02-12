extends Panel

var _empty = true


#-------------------------------------------------------------------------------
func is_empty() -> bool:
	return _empty


#-------------------------------------------------------------------------------
func set_resource(resource : ResourceType, quantity : int) -> void:
	# Sets the texture region, quantity text, and is no longer empty.
	$ResourceTexture.texture.region = resource.texture_region
	$QuantityLabel.text = str(quantity)
	_empty = false


#-------------------------------------------------------------------------------
func set_quantity(quantity : int) -> void:
	$QuantityLabel.text = str(quantity)


#-------------------------------------------------------------------------------
func clear() -> void:
	$ResourceTexture.texture.region = Rect2()
	$QuantityLabel.text = ""
	_empty = true


#-------------------------------------------------------------------------------
func _ready() -> void:
	# Makes each texture a unique resource so we can set individually.
	$ResourceTexture.texture = $ResourceTexture.texture.duplicate()


#-------------------------------------------------------------------------------
