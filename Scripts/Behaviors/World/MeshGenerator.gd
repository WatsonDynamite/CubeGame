@tool
class_name MeshGenerator

static func generateTerrainMesh(heightMap: Array, colorMap: PackedColorArray, heightMultiplier: float, meshHeightCurve: Curve ) -> ArrayMesh:
	var size: int = heightMap.size();
	var img = Image.create_from_data(size, size, false, Image.FORMAT_RGBAF, colorMap.to_byte_array());
	print("flipping")
	img.rotate_90(COUNTERCLOCKWISE)
	#img.rotate_180();
	img.flip_x();
	#img.flip_y();
	var tex: ImageTexture = ImageTexture.create_from_image(img);
	
	var mat = StandardMaterial3D.new();
	mat.albedo_texture = tex;
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST;
	
	
	var plane_mesh = PlaneMesh.new();
	var arrayMesh = ArrayMesh.new();
	var st = SurfaceTool.new();
	
	
	plane_mesh.size = Vector2(size, size);
	plane_mesh.subdivide_depth = size - 2;
	plane_mesh.subdivide_width = size - 2;
	
	st.create_from(plane_mesh, 0);
	
	var arrays = st.commit_to_arrays();
	var vertices = arrays[ArrayMesh.ARRAY_VERTEX];

	
	print("map size squared: ", pow(size, 2));
	print("vertices size: ", vertices.size());
	
	
	for y in size:
		for x in size:
			var height = heightMap[x][y];
			var curVertex = vertices[(y*size + x)]
			vertices[(y*size + x)] = Vector3(x, meshHeightCurve.sample(height) * heightMultiplier, y);
	#for i in vertices.size():
	#	var vertex = vertices[i];
	#	var height = heightMap[vertex.z][vertex.x]
	#	vertices[i].y = meshHeightCurve.sample(height) * heightMultiplier
	
	arrayMesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays);
	st.create_from(arrayMesh, 0);
	
	st.set_material(mat);
	st.generate_normals();
	return st.commit();
