@tool
extends Node

@onready
var plane: MeshInstance3D;

# Called when the node enters the scene tree for the first time.
func _ready():
	plane = get_parent().find_child("Plane");
	pass # Replace with function body.
	
	
func drawNoiseMap(noiseMap: Array):
	var size: int = noiseMap.size();
	
	var colorMap: PackedColorArray = PackedColorArray();
	for y in size:
		for x in size:
			colorMap.append(lerp(Color.BLACK, Color.WHITE, noiseMap[y][x]));
	
	var img = Image.create_from_data(size, size, false, Image.FORMAT_RGBAF, colorMap.to_byte_array());
	var tex: ImageTexture = ImageTexture.create_from_image(img);
	
	plane.get_active_material(0).set_texture(0, tex);
	plane.scale = Vector3(size, 1, size);
	
func drawColorMap(colorMap: PackedColorArray, size: int):

	var img = Image.create_from_data(size, size, false, Image.FORMAT_RGBAF, colorMap.to_byte_array());
	var tex: ImageTexture = ImageTexture.create_from_image(img);
	
	plane.get_active_material(0).set_texture(0, tex);
	plane.scale = Vector3(size, 1, size);

