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
@export
var meshHeightCurve: Curve;

@export var execute_button: bool = false:
	set = _set_execute_button;

@onready
var MapDisplay = $MapDisplay

var regions: Array[TerrainType] = [
	TerrainType.new("Water_Deep", 0.3, Color.DARK_BLUE),
	TerrainType.new("Water", 0.4, Color.BLUE),
	TerrainType.new("Sand", 0.5, Color.SANDY_BROWN),
	TerrainType.new("Grass", 0.55, Color.GREEN),
	TerrainType.new("Grass_2", 0.6, Color.DARK_GREEN),
	TerrainType.new("Rock", 0.7, Color.SADDLE_BROWN),
	TerrainType.new("Rock", 0.8, Color.SIENNA),
	TerrainType.new("Mountain", 0.9, Color.SLATE_GRAY),
	TerrainType.new("Snow", 1, Color.WHITE),
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
			MapDisplay.drawMesh(MeshGenerator.generateTerrainMesh(noiseMap, colorMap, meshHeightMultiplier, meshHeightCurve));
	
	
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
