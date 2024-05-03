@tool
class_name CustomNoise;

static func generateNoiseMap(size: int, scale: int, octaves: int, persistence: float, lacunarity: float) -> Array[Array]:
	randomize();
	var noiseMap: Array[Array] = []
	
	
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH;
	noise.set_seed(randi())
	
	if (scale <= 0): scale = 0.001;
	
	var maxNoiseHeight: float = -2;
	var minNoiseHeight: float = 2;
	
	for y in size:
		noiseMap.append([])
		for x in size:
			var amplitude: float = 1;
			var frequency: float = 1;
			var noiseHeight: float = 0;
			
			for i in octaves:
				var sample_x: float = x / scale * frequency;
				var sample_y: float = y / scale * frequency;
				
				var perlinValue = noise.get_noise_2d(sample_x, sample_y);
				noiseHeight += perlinValue * amplitude;
				
				amplitude *= persistence;
				frequency *= lacunarity;
			if(noiseHeight > maxNoiseHeight): maxNoiseHeight = noiseHeight;
			if(noiseHeight < minNoiseHeight): minNoiseHeight = noiseHeight;
			
			noiseMap[y].append(noiseHeight);
	for y in size:
		for x in size:
			var lerped = inverse_lerp(minNoiseHeight, maxNoiseHeight, noiseMap[y][x]);
			if(lerped < 0):
				print("lerped: ", lerped, " minNoiseHeight: ", minNoiseHeight, " MaxNoiseHeight: ", maxNoiseHeight);
			noiseMap[y][x] = lerped
			
	return noiseMap;
