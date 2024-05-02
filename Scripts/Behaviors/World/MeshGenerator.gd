@tool
class_name MeshGenerator

static func generateTerrainMesh(heightMap: Array, colorMap: PackedColorArray, heightMultiplier: float ) -> ArrayMesh:
	var size: int = heightMap.size();
	
	var img = Image.create_from_data(size, size, false, Image.FORMAT_RGBAF, colorMap.to_byte_array());
	var tex: ImageTexture = ImageTexture.create_from_image(img);
	
	var mat = StandardMaterial3D.new();
	mat.albedo_texture = tex;
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST;
	
	
	var plane_mesh = PlaneMesh.new();
	var arrayMesh = ArrayMesh.new();
	var st = SurfaceTool.new();
	
	
	plane_mesh.size = Vector2(size, size);
	plane_mesh.subdivide_depth = size;
	plane_mesh.subdivide_width = size;
	
	st.create_from(plane_mesh, 0);
	
	var arrays = st.commit_to_arrays();
	
	var vertices = arrays[ArrayMesh.ARRAY_VERTEX];
	
	for i in vertices.size():
		var vertex = vertices[i];
		var height = heightMap[vertex.x][vertex.z]
		vertices[i].y = height * heightMultiplier * 1 + exp(height);
	#arrays[Mesh.ARRAY_VERTEX] = meshData.vertices;
	#arrays[Mesh.ARRAY_TEX_UV] = meshData.uvs;
	# Create the Mesh.
	arrayMesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays);
	
	
	st.create_from(arrayMesh, 0);
	st.generate_normals();
	
	
	st.set_material(mat);
	return st.commit();
