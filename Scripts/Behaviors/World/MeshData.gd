@tool

class_name MeshData

var mapSize: int;
var vertices: PackedVector3Array = [];
var triangles: PackedInt64Array = [];
var uvs: PackedVector2Array = [];

var triangleIndex: int = 0; 

func _init(size: int):
	mapSize = size;
	vertices.resize(pow(size, 2));
	uvs.resize(pow(size, 2));
	triangles.resize((size - 1) * (size-1) * 6);

func addTriangle(a: int, b: int, c: int):
	triangles[triangleIndex] = a;
	triangles[triangleIndex+1] = b;
	triangles[triangleIndex+2] = c;
	
func createMesh(colorMap: PackedColorArray):
	
	var img = Image.create_from_data(mapSize, mapSize, false, Image.FORMAT_RGBAF, colorMap.to_byte_array());
	var tex: ImageTexture = ImageTexture.create_from_image(img);
	
	var mat = StandardMaterial3D.new();
	mat.albedo_texture = tex;
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST;
	
	
	var arrayMesh = ArrayMesh.new();
	var arrays = [];
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs;
	# Create the Mesh.
	arrayMesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var st = SurfaceTool.new();
	st.set_material(mat);
	st.create_from(arrayMesh, 0);
	st.generate_normals();
	return st.commit();

	
	
