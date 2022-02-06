extends Node
tool
var map = [[]]
const WIDTH = 100
const HEIGHT = 100

var open_simplex_noise: OpenSimplexNoise

var params = {
	# Number of OpenSimplex noise layers that are sampled to get the fractal noise. 
	# Higher values result in more detailed noise but take more time to generate.
	# Have a min vlaue of 1 and max of 9.
	"octaves": 2,
	 
	# Period of the base octave. A lower period results in higher-frequency noise
	# 	(more value changes accross the same distance).
	"period": 64,
	
	# Difference in period between octaves.
	"lacunarity": 2.0,
	
	# The contribution factor of the different octaves. A persistence value of 1 
	# 	means all octaves have the same contribution, a value of 0.5 means each
	# 	octave contributes half as much as the previous one.
	"persistence": 0.75,
	
	# Whether or not the seed is randomised when generate is called.
	"randomize_seed": true,
}

func _get_property_list():
	return [
		{ name = "octaves", hint = PROPERTY_HINT_RANGE, hint_string = "1,9,1", type = TYPE_REAL },
		{ name = "period", hint = PROPERTY_HINT_RANGE, hint_string = "-500,500", type = TYPE_REAL },
		{ name = "lacunarity", hint = PROPERTY_HINT_RANGE, hint_string = "-5,5", type = TYPE_REAL },
		{ name = "persistence", hint = PROPERTY_HINT_RANGE, hint_string = "-5,5", type = TYPE_REAL },
		{ name = "randomize_seed", type = TYPE_BOOL },
		{ name = "generate", type = TYPE_BOOL },
	]
		

func _set(property, value):
	if params.has(property):
		params[property] = value
	generate_world()

func _get(property):
	if params.has(property):
		return params[property]


func _ready():
	generate_world()

func generate_world():
	map.clear()
	for x in WIDTH:
		map.append([])
		for y in HEIGHT:
			map[x].append([])
			map[x][y] = 0
	randomize()
	open_simplex_noise = OpenSimplexNoise.new()
	open_simplex_noise.seed = randi()
	
	open_simplex_noise.octaves = params.octaves
	open_simplex_noise.period = params.period
	open_simplex_noise.lacunarity = params.lacunarity
	open_simplex_noise.persistence = params.persistence
	
	for x in WIDTH:
		for y in HEIGHT:
			map[x][y] = get_tile_index(open_simplex_noise.get_noise_2d(float(x), float(y)))
			

func get_tile_index(noise_sample):
	if noise_sample < -0.4:
		return Tile.Type.WATER
	if noise_sample < -0.1:
		return Tile.Type.GRASS
	if noise_sample < 0.0:
		return Tile.Type.FARM
	if noise_sample < 0.15:
		return Tile.Type.GRASS
	if noise_sample < 0.5:
		return Tile.Type.FOREST
	return Tile.Type.STONE
