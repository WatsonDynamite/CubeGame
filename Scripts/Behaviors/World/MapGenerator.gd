@tool
extends Node

enum DrawMode { NOISE, COLOR, MESH }

@export var drawMode = DrawMode.MESH;

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
@export
var meshHeightMultiplier: float = 16;

@export var execute_button: bool = false:
	set = _set_execute_button;

@onready
var MapDisplay = $MapDisplay

var regions: Array[TerrainType] = [
	TerrainType.new("Water", 0.2, Color.BLUE),
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
			#NOTE: color map is rotated 90 degrees counterclockwise and mirrored compared to the noise map
			#this is why we access [y][x] and not [x][y]
			var currentHeight = noiseMap[y][x];
			for r in regions.size():
				if(currentHeight <= regions[r].height):
					colorMap.append(regions[r].color);
					break;
	
	ImageGenerator.createImages(noiseMap, colorMap);
	match drawMode:
		DrawMode.COLOR:
			MapDisplay.drawColorMap(colorMap, mapSize);
		DrawMode.NOISE:
			MapDisplay.drawNoiseMap(noiseMap);
		DrawMode.MESH:
			MapDisplay.drawMesh(MeshGenerator.generateTerrainMesh(noiseMap, colorMap, meshHeightMultiplier));
	
	
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
