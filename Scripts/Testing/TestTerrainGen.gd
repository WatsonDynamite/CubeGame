extends VoxelGeneratorScript

const channel : int = VoxelBuffer.CHANNEL_TYPE

func _get_used_channels_mask() -> int:
	return 1 << channel

func _generate_block(buffer : VoxelBuffer, origin : Vector3i, lod : int) -> void:
	if lod != 0:
		return
	if origin.y < 0:
		buffer.fill(1, channel)
	if origin.x == origin.z and origin.y < 1:
		buffer.fill(1, channel)
