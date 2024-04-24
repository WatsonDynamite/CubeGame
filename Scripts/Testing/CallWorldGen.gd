extends Node3D

const MyGenerator = preload("TestTerrainGen.gd")

# Get the terrain
@onready var terrain = $VoxelTerrain

func _ready():
	if(terrain && MyGenerator):
		terrain.generator = MyGenerator.new();
