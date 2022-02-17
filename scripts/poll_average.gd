extends Control


func update_carbon_label():
	$carbon/c.text = str(Pollution.carbon)
	
	
func update_tree_pollution_label():
	var sum = Pollution.tree_pollution / Pollution.forest_tiles
	var percent = sum * 100.0
	$tp/tp2.text = str(percent) + "%"
	

func update_water_pollution_label():
	$wp/wp2.text = str(Pollution.water_pollution) + "%"


func update_mountain_pollution_label():
	$mp/mp2.text = str(Pollution.mountain_pollution) + "%"


func update_grass_pollution_label():
	$gp/gp2.text = str(Pollution.grass_pollution) + "%"
	
	
func total_pollution():
	var sum = Pollution.total()
	$op/pre.text = str(sum) + "%"

func total():
		var sum = Pollution.total()
		return sum


func show() -> void:
	.show() # Calls show on the base class.
	
	# Updates all the labels.
	update_tree_pollution_label()
	update_grass_pollution_label()
	update_carbon_label()
	update_mountain_pollution_label()
	update_water_pollution_label()
	total_pollution()
