extends StaticBody2D

var kinds = [
	"res://assets/nature/tree1.png",
	"res://assets/nature/tree2.png",
	"res://assets/nature/tree4.png",
	"res://assets/nature/tree.png"
	];
	
func init(i):
	$Sprite.set_texture(load(kinds[i]));
