extends Node
const WIDTH = 100
const HEIGHT = 100
var noise_seed = 0
var octaves = 5
var period = 11
var lacunarity = 1.5
var persistence = 0.5
var use_data = false

func _ready():
	randomize()
	noise_seed = randi()
 
