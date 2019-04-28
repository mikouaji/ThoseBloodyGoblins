extends Node2D

var goblins = [];
var nests = [];
var high_score = 0;
var initial_nests = 1;
var ground = null;

signal nest_added;
signal mob_added;

func _ready():
	get_tree().paused = true;
	pass 
	


func _on_Player_score(score):
	if score > high_score:
		high_score = score;


func _on_Player_he_ded_man(score, kills):
	get_tree().paused = true;
	var go = $guis/GameOver;
	go.set_score(score);
	go.set_kills(kills);
	go.set_high_score(high_score);
	go.show();
	
func new_game():
	clear_map();
	ground = preload("res://scenes/Floor.tscn").instance();
	self.add_child(ground);
	ground.init();
	$Player.reset_stats();
	$Player.reset_gui();
	$Player.show();
	$guis/GUI.show();
	spawn_nests(initial_nests);
	get_tree().paused = false;

func clear_map():
	if ground != null:
		ground.queue_free();
	for g in goblins:
		g.queue_free();
	for n in nests:
		n.queue_free();
	nests = [];
	goblins = [];

func spawn_nests(count):
	var rect = ground.get_used_rect();
	var border = ground.wall * 1.5;
	var mapStart = ground.map_to_world(Vector2(rect.position.x + border, rect.position.y + border));
	var mapEnd = ground.map_to_world(Vector2(rect.end.x - border, rect.end.y - border));
	for i in count:
		var nest = preload("res://scenes/Nest.tscn").instance();
		self.add_child(nest);
		nest.init(mapStart, mapEnd);
		nests.append(nest);
		emit_signal("nest_added", nests.size());
	pass

func _on_Welcome_start():
	$guis/Welcome.hide();
	new_game();
	pass # Replace with function body.


func _on_GameOver_new_game():
	$guis/GameOver.hide();
	$Player.hide();
	new_game();
	pass # Replace with function body.

func _on_mob_spawn(mob):
	goblins.append(mob);
	emit_signal("mob_added", goblins.size());
	
func _on_nest_dead(nest):
	nests.remove(nests.find(nest));
	nest.queue_free();
	emit_signal("nest_added", nests.size());
	
func _on_Goblin_death(goblin):
	goblins.remove(goblins.find(goblin));
	goblin.queue_free();
	emit_signal("mob_added", goblins.size());

func _on_Player_lvl_change(e):
	if(e % 2 == 1):
		spawn_nests(1);
	pass # Replace with function body.
