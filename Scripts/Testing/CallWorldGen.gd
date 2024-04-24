extends Node3D

const PerFal = preload("res://Scripts/Behaviors/World/PerlinFalloff.gd")

const Player = preload("res://Prefabs/player.tscn");

# const MyGenerator = preload("res://Scripts/Testing/TestTerrainGen.gd");

# Get the terrain
@onready var terrain: VoxelTerrain = $VoxelTerrain
@onready var water = $Water;

func _ready():
	if(terrain && PerFal):
		var size = 2048;
		var offset = size / 2;
		var perfal = PerFal.new(size);
		
		var playerSpawnPoint = perfal.get_viable_spawn_point_xy();
		var voxelTool: VoxelTool = terrain.get_voxel_tool();
		
		var gen = VoxelGeneratorImage.new();
		
		water.scale = Vector3(size, 1, size);
		
		gen.channel = VoxelBuffer.CHANNEL_TYPE;
		gen.image = perfal.to_image();
		
		terrain.bounds = AABB(Vector3(0, -60, 0), Vector3(size, 9999, size));
		terrain.generator = gen;
		
		var hit = voxelTool.raycast(Vector3(playerSpawnPoint.x, 512, playerSpawnPoint.y), Vector3.DOWN, 999999);
		print(hit);
		var instance = Player.instantiate();
		
		if(hit && hit.position):
			instance.position = hit.position;
		else:
			instance.position = Vector3(playerSpawnPoint.x, 256, playerSpawnPoint.y)
		
		
		add_child(instance);
		


