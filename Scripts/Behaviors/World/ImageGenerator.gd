@tool
extends Node


class_name ImageGenerator
	
static func createImages(noiseMap: Array, colorMap: PackedColorArray):
	var size: int = noiseMap.size();
	createNoiseImage(noiseMap, size);
	createColorImage(colorMap, size);
	
	pass;

static func createColorImage(colorMap: PackedColorArray, size: int):
	var img = Image.create_from_data(size, size, false, Image.FORMAT_RGBAF, colorMap.to_byte_array());
	img.save_png("res://Maps/color.png");

static func createNoiseImage(noiseMap: Array, size: int):
	var colorMap: PackedColorArray = PackedColorArray();
	for y in size:
		for x in size:
			colorMap.append(lerp(Color.BLACK, Color.WHITE, noiseMap[y][x]));
	
	var img = Image.create_from_data(size, size, false, Image.FORMAT_RGBAF, colorMap.to_byte_array());
	img.save_png("res://Maps/noise.png");
	return img;
	
	
