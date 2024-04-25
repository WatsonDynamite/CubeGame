extends Node

class_name PerlinFalloff;

var height_noise: FastNoiseLite;
var height_map: PackedFloat64Array;

var size;
var octaves = 4;

func _init(sz: int):
	
	randomize();
	
	height_noise = FastNoiseLite.new();
	height_noise.seed = randi();
	height_noise.noise_type = FastNoiseLite.TYPE_PERLIN;
	height_noise.frequency = 0.002;
	
	size = sz;
	
	generate();
	
func generate():
	for y in size:
		for x in size:
			var value = 0;
			
			for o in octaves:
				value += height_noise.get_noise_2d(x,y);
			
			var falloff: float = get_falloff(x, y);
			
			var trueval = abs(abs(value) * falloff);
			height_map.append(trueval);
	return height_map;

func to_image():
	var image = Image.new();

	image.create(size, size, false, Image.FORMAT_RGB8);
	
	var buffer = PackedByteArray();
	buffer.resize(size * size * 3);
	buffer = image.get_data();
	
	for y in size:
		for x in size:
			var grayscale_value = int((height_map[y * size + x]) * 127.5)
			buffer.append(grayscale_value) # Red
			buffer.append(grayscale_value) # Green
			buffer.append(grayscale_value) # Blue
	
	image.set_data(size, size, false, Image.FORMAT_RGB8, buffer);
	image.save_png("res://Maps/world.png");
	return image;

func get_falloff(x, y):
	var center = size /2 ;
	
	var dist = sqrt( #distance to center, normalized from 0 to 1
		pow(center - x, 2)
		+
		pow(center - y, 2)
	) / (center * sqrt(2));
	
	var a = 3;
	var b = 2;
	var auxpow = pow(dist, 2)
	return (- auxpow / (auxpow + pow(b - b * dist, a)) + 1);


func get_viable_spawn_point_xy():
	randomize();
	var auxMap = height_map.duplicate();
	auxMap.sort();
	var highestPeak = auxMap[auxMap.size() - 1];
	
	var searchArr: Array = [];
	
	for i in auxMap.size():
		if(auxMap[i] >= highestPeak - 0.5):
			searchArr.append(auxMap[i]);
	
	var selectedSpawn = searchArr[randi_range(0, searchArr.size() - 1)];
	var selectedSpawnIdx = auxMap.find(selectedSpawn);
	
	if(selectedSpawnIdx != -1):
		var x = selectedSpawnIdx % size;
		var y = int(selectedSpawnIdx / size);
		return Vector2(x, y);
		
	
	
