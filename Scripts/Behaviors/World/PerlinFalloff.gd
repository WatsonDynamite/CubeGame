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
	height_noise.frequency = 0.004;
	
	size = sz;
	
	
func generate():
	for y in size:
		for x in size:
			var value = 0;
			
			for o in octaves:
				value += height_noise.get_noise_2d(x,y);
			
			var falloff: float = get_falloff(x, y);
			
			var trueval = abs(value * falloff);
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

