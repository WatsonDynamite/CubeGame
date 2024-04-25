@tool
extends Node

@export
var mapSize: int;
@export
var noiseScale: float;
@export
var octaves: int;
@export
var persistence: float;
@export
var lacunarity: float;

@export var execute_button: bool = false:
	set = _set_execute_button;

@onready
var MapDisplay = $MapDisplay

var regions: Array[TerrainType] = [
	TerrainType.new("Water", 0.35, Color.BLUE),
	TerrainType.new("Sand", 0.4, Color.SANDY_BROWN),
	TerrainType.new("Land", 0.7, Color.GREEN),
	TerrainType.new("Mountain", 1, Color.SLATE_GRAY),
];


func _ready():
	generateMap();

func generateMap():
	randomize();
	
	var noiseMap: Array = CustomNoise.generateNoiseMap(mapSize, noiseScale, octaves, persistence, lacunarity);
	
	var colorMap: PackedColorArray = [];
	
	for y in mapSize:
		for x in mapSize:
			var currentHeight = noiseMap[x][y];
			for r in regions.size():
				if(currentHeight <= regions[r].height):
					colorMap.append(regions[r].color);
					break;
	
	MapDisplay.drawColorMap(colorMap, mapSize);
	#MapDisplay.drawNoiseMap(noiseMap);
	
	
func _set_execute_button(new_value: bool) -> void:
	execute_button = false;
	generateMap();

	
class TerrainType:
	var name: String;
	var height: float;
	var color: Color;
	
	func _init(n, h, c):
		name = n;
		height = h;
		color = c;
