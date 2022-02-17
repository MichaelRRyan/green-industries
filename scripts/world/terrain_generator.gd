extends Node
signal world_generated(terrain_tiles)
tool

# ------------------------------------------------------------------------------
# SIMPLEX NOISE PROPERTY DESCRIPTIONS
# ------------------------------------------------------------------------------
# === OCTAVES ===
# Number of OpenSimplex noise layers that are sampled to get the fractal noise. 
# Higher values result in more detailed noise but take more time to generate.
# Have a min vlaue of 1 and max of 9.
#
# === PERIOD ===
# Period of the base octave. A lower period results in higher-frequency noise
# 	(more value changes accross the same distance).
#
# === LACUNARITY ===
# Difference in period between octaves.
#
# === PERSISTENCE ===
# The contribution factor of the different octaves. A persistence value of 1 
# 	means all octaves have the same contribution, a value of 0.5 means each
# 	octave contributes half as much as the previous one.

var params = {
	"height/octaves": 2,
	"height/period": 64,
	"height/lacunarity": 2.0,
	"height/persistence": 0.75,
	"vegetation/octaves": 2,
	"vegetation/period": 64,
	"vegetation/lacunarity": 2.0,
	"vegetation/persistence": 0.75,
	"randomize_seed": true,
}

const WIDTH = 100
const HEIGHT = 100

func _get_property_list():
	return [
		{ name = "height/octaves", hint = PROPERTY_HINT_RANGE, hint_string = "1,9,1", type = TYPE_REAL },
		{ name = "height/period", hint = PROPERTY_HINT_RANGE, hint_string = "-500,500", type = TYPE_REAL },
		{ name = "height/lacunarity", hint = PROPERTY_HINT_RANGE, hint_string = "-5,5", type = TYPE_REAL },
		{ name = "height/persistence", hint = PROPERTY_HINT_RANGE, hint_string = "-5,5", type = TYPE_REAL },
		{ name = "vegetation/octaves", hint = PROPERTY_HINT_RANGE, hint_string = "1,9,1", type = TYPE_REAL },
		{ name = "vegetation/period", hint = PROPERTY_HINT_RANGE, hint_string = "-500,500", type = TYPE_REAL },
		{ name = "vegetation/lacunarity", hint = PROPERTY_HINT_RANGE, hint_string = "-5,5", type = TYPE_REAL },
		{ name = "vegetation/persistence", hint = PROPERTY_HINT_RANGE, hint_string = "-5,5", type = TYPE_REAL },
		{ name = "randomize_seed", type = TYPE_BOOL },
		{ name = "generate", type = TYPE_BOOL },
	]
		

# ------------------------------------------------------------------------------
func _set(property, value):
	if params.has(property):
		params[property] = value
		
	if Engine.editor_hint:
		generate_world()


# ------------------------------------------------------------------------------
func _get(property):
	if params.has(property):
		return params[property]


# ------------------------------------------------------------------------------
func generate_world():

	var height_map = OpenSimplexNoise.new()
	var vegetation_map = OpenSimplexNoise.new()
	
	# If running in the editor, uses the generation's own properties.
	if Engine.editor_hint:
		# Sets the height map noise properties.
		if params["randomize_seed"]:
			height_map.seed = randi()
			
		height_map.octaves = params["height/octaves"]
		height_map.period = params["height/period"]
		height_map.lacunarity = params["height/lacunarity"]
		height_map.persistence = params["height/persistence"]
		
		# Sets the vegetation map noise properties.
		if params["randomize_seed"]:
			vegetation_map.seed = randi()
			
		vegetation_map.octaves = params["vegetation/octaves"]
		vegetation_map.period = params["vegetation/period"]
		vegetation_map.lacunarity = params["vegetation/lacunarity"]
		vegetation_map.persistence = params["vegetation/persistence"]
	
	# If running in the game, uses terrain data's properties.
	else:
		# Sets the height map noise properties.
		height_map.seed = TerrainData.noise_seed
		height_map.octaves = TerrainData.height_octaves
		height_map.period = TerrainData.height_period
		height_map.lacunarity = TerrainData.height_lacunarity
		height_map.persistence = TerrainData.height_persistence
		
		# Sets the vegetation map noise properties.
		vegetation_map.seed = TerrainData.noise_seed
		vegetation_map.octaves = TerrainData.vegetation_octaves
		vegetation_map.period = TerrainData.vegetation_period
		vegetation_map.lacunarity = TerrainData.vegetation_lacunarity
		vegetation_map.persistence = TerrainData.vegetation_persistence
		
	var tiles = []
	
	for x in WIDTH:
		tiles.append([])
		
		for y in HEIGHT:
			tiles[x].append(0)
			
			var noise_sample = height_map.get_noise_2d(float(x), float(y))
			tiles[x][y] = _get_tile_from_height(noise_sample)
			
			if Tile.Type.GRASS == tiles[x][y]:
				noise_sample = vegetation_map.get_noise_2d(float(x), float(y))
				tiles[x][y] = _get_tile_from_vegetation(noise_sample)
	
	emit_signal("world_generated", tiles)	


# ------------------------------------------------------------------------------
func _get_tile_from_height(noise_sample):
	if noise_sample < -0.3:
		return Tile.Type.WATER
		
	if noise_sample < 0.3:
		return Tile.Type.GRASS
		
	return Tile.Type.STONE


# ------------------------------------------------------------------------------
func _get_tile_from_vegetation(noise_sample):
	if noise_sample < -0.1:
		return Tile.Type.GRASS
		
	if noise_sample < 0.0:
		return Tile.Type.MEADOW
		
	if noise_sample < 0.15:
		return Tile.Type.GRASS
		
	if noise_sample < 0.5:
		
		return Tile.Type.FOREST
		
	return Tile.Type.GRASS


# ------------------------------------------------------------------------------
