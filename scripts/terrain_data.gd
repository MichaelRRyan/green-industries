extends Node
const WIDTH = 100
const HEIGHT = 100
var noise_seed = 0

var height_octaves = 3
var height_period = 9.6
var height_lacunarity = 0.25
var height_persistence = 0.39

var vegetation_octaves = 3
var vegetation_period = 12.075
var vegetation_lacunarity = 2.85
var vegetation_persistence = 0.7

var use_data = false

func _ready():
	randomize()
	noise_seed = randi()
 
