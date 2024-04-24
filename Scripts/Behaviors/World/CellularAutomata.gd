extends Node

class_name CellularAutomata

var size: int;
var generations: int


func _init(sz: int, gens: int ):
	size = sz;
	generations = gens;
	pass;


func test_generate() -> Image:
	var image: Image = Image.create(size, size, false, Image.FORMAT_RGBA8);
	
	for x in size:
		for y in size:
			image.set_pixel(x, y, Color.GREEN);
			
	return image;

func generate() -> Array:
	var grid = [];
	
	var create_limit = 3;
	var destroy_limit = 5;
	
	#generate grid
	
	for i in size:
		grid.append([])
		for j in size:
			grid[i].append(false);
	
	
	#seed randoms
	randomize();
	
	for r in range((size / 2) - 10, (size / 2) + 10):
		for t in range((size / 2) - 10, (size / 2) + 10):
			grid[r][t] = true if randi_range(0, 1) == 1 else false;
	
	for x in generations:
		# rules for cellular automata:
		# - Thresholds for Birth: 0 live neighbors or 3 or more live neighbors
		print("generation: ", x);
		for i in size:
			for j in size:
				var me = grid[i][j];
				var neighbors = get_neighbors(grid, i, j);
				var living_neighbors = neighbors.filter(func(itm): return grid[itm.x][itm.y]);
				var dead_neighbors = neighbors.filter(func(itm): return !grid[itm.x][itm.y]);
				
				randomize();
				if(!me): #if dead
					if(living_neighbors.size() >= 2):
						grid[i][j] = true; #live
				else: #if alive
					if(living_neighbors.size() > 1 && dead_neighbors.size() > 3):
						var idx = randi_range(0, dead_neighbors.size() - 1);
						var neighbor_to_live = dead_neighbors[idx];
						grid[neighbor_to_live.x][neighbor_to_live.y] = true;

	return grid;
	pass;

func make_image(grid: Array) -> Image:
	var image: Image = Image.create(size, size, false, Image.FORMAT_RGBA8);
	
	
	for i in size:
		for j in size:
			var color = Color.WHITE if grid[i][j] else Color.BLACK;
			image.set_pixel(i, j, color);
	
	return image;

func get_neighbors(grid: Array, x: int, y: int) -> Array:
	var neighbors = [];
	
	for i in range(-1, 1):
		for j in range(-1, 1):
			var neighbor_x = x + i
			var neighbor_y = y + j
			
			# Skip if the neighbor is the current cell itself
			if i == 0 and j == 0:
				continue
			
			# Check if neighbor coordinates are within bounds
			if neighbor_x >= 0 and neighbor_x < size and neighbor_y >= 0 and neighbor_y < size:
				neighbors.append(Vector2(neighbor_x,neighbor_y));
	return neighbors
