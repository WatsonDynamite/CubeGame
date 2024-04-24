extends Node2D


var cellularAutomata = preload("res://Scripts/Behaviors/World/CellularAutomata.gd");
var perlinFalloff = preload("res://Scripts/Behaviors/World/PerlinFalloff.gd");

@onready
var shapeMap = $ShapeMap;

func _ready():
	
	const size = 1024;
	
	var perFal = perlinFalloff.new(size);
	perFal.generate();
	
	shapeMap.texture = ImageTexture.create_from_image(perFal.to_image());
	
	pass;

	
