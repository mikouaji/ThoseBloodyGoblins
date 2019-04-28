extends TileMap

var startX = -100;
var startY = -100;
var cells = 100;
var wall = 20;

var sometimes = 0.6;
var rand = null;
var trees = [];

	
func init():
	clear();
	rand = RandomNumberGenerator.new();
	for i in range(startX, cells):
		for j in range( startY, cells):
			#grass
			set_cell(i,j,rand.randi_range(0,8));
			#trees
			if i == startX  or i == cells-1  or j == startY  or j == cells-1:
				if	(i+j) % 2 == 0:
					plant_tree(i,j);
			elif i < startX + wall or i > cells - wall or j < startY + wall or j > cells - wall:
				plant_tree_sometimes(i,j);
			else:
				plant_tree_almost_never(i,j);
			
	pass	

func plant_tree_almost_never(i,j):
	rand.randomize();
	if(rand.randf() < 0.01):
		plant_tree(i,j);

func plant_tree_sometimes(i,j):
	rand.randomize();
	if(rand.randf() > sometimes):
		plant_tree(i,j);

func plant_tree(i,j):
	var tree = preload("res://scenes/Tree.tscn").instance();
	rand.randomize();
	tree.init(rand.randi_range(0, tree.kinds.size()-1));
	tree.position = map_to_world(Vector2(i,j)) + Vector2(32,32);
	trees.append(tree);
	add_child(tree);