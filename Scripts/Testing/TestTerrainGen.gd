extends VoxelGeneratorScript

class_name TestTerrainGen

const channel : int = VoxelBuffer.CHANNEL_TYPE

var perlinFalloff = preload("res://Scripts/Behaviors/World/PerlinFalloff.gd");
var perFal;
var size;

var heightMap;

func _init(sz: int):
	size = sz;
	perFal = perlinFalloff.new(size);
	heightMap = perFal.generate();
	perFal.to_image();
	print("heightmap")
	print("heightmap size: ", heightMap.size());
	pass;

func _get_used_channels_mask() -> int:
	return 1 << channel

func _generate_block(buffer : VoxelBuffer, origin : Vector3i, lod : int) -> void:
	if lod != 0:
		return;
		
	var edit: VoxelTool = buffer.get_voxel_tool();
	if origin.y < 0:
		buffer.fill(1, channel)
	elif(origin.x < 0 || origin.z < 0 ||origin.x > size || origin.z > size):
		edit.set_voxel(Vector3(origin.x, origin.y, origin.z), 1);
	else:
		pass;
		var sample = heightMap[origin.x * size + origin.z];
		edit.set_voxel(Vector3(origin.x, sample * 1000, origin.z), 1);
