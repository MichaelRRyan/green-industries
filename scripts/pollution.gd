extends Control
var count_g = 0
var count_t = 0
var count_w = 0
var count_s = 0
var health=0

var water_tiles = 0
var grass_tiles = 0
var farm_tiles = 0
var forest_tiles = 0 # tree deciptation(amount of tree tiles ^^)
var stone_tiles = 0 #mountain decpation 

var grass_pollution = 0
var tree_pollution = 0.0 
var water_pollution = 0.0 
var mountain_pollution = 0.0 
var carbon = 0.0 # from all the factories and coal powerplants, more of them present the higher it gets
var factory_amount = 0#add this to factory 
var pd = 0 #pollution deciptation? (down poll)
var td = 0 # tree deciptation(amount of tree tiles ^^)
var overall_pollution = [water_pollution,tree_pollution,mountain_pollution,grass_pollution]
const MAX_POLLUTION = 10.0 #end state
var pollut=false
var gone = false


func set_carbon(var carbons):
	carbon = carbons
	
func set_tree_pollution(var trees): #tree 
	tree_pollution = trees

func set_grass_pollution(var grass): #grass
	grass_pollution = grass
	
func set_water_pollution(var water):
	water_pollution = water


func set_mountain_pollution(var stone):
	mountain_pollution = stone
	
	
func total():
	# Amount polluted overall.
	var sum = grass_pollution + tree_pollution + carbon + water_pollution + mountain_pollution 
	var average = sum / 5
	var v = average / MAX_POLLUTION

	return v * 100.0 # A percentage.
	

