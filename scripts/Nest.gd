extends KinematicBody2D

var max_exp = 2000;
var min_exp = 300;

var max_hp = 1000;
var min_hp = 300;

var initial = 3;

var types = [1,2,3,4,5,6];
var min_dist = 10;
var max_dist = 30;

var stats = {
	'exp' : 0,
	'hp' : 0,
	'initial' : 0,
	'spawn_time' : 9,
};
var timer;
var can_spawn = true;

signal spawn;
signal death;

func init(start, end):
	self.connect("spawn", get_parent(), "_on_mob_spawn");
	self.connect("death", get_parent(), "_on_nest_dead");
	self.connect("death", $"../Player", "_on_nest_dead");
	var rand = RandomNumberGenerator.new();
	rand.randomize();
	position = Vector2(rand.randi_range(start.x, end.x), rand.randi_range(start.y, end.y));
	stats.exp = rand.randi_range(min_exp, max_exp);
	stats.hp = rand.randi_range(min_hp, max_hp);
	stats.initial = initial;
	spawn_mobs(rand, stats.initial);
	pass;

func _physics_process(delta):
	if stats.hp <= 0:
		if(!$DeathAnmiation.is_playing()):
			death();
	else:
		if can_spawn:
			can_spawn = false;
			timer = Timer.new();
			add_child(timer);
			timer.connect("timeout", self, "_on_spwan_timer");
			timer.set_wait_time(stats.spawn_time);
			timer.set_one_shot(true);
			timer.start();
			spawn_mobs(RandomNumberGenerator.new(),1);
	pass

func _on_spwan_timer():
	can_spawn = true;

func death():
	$AudioDeath.play();
	$DeathAnmiation.frame=0;
	$DeathAnmiation.play();
	
func spawn_mobs(rand, count):
	rand.randomize();
	for i in count:
		var k = 1;
		if randf() > 0.5:
			k = -1;
		var x = 0;
		var x1 = position.x + ( k * min_dist);
		var x2 = position.x + ( k * max_dist)
		if(x1<x2):
			x = rand.randi_range(x1,x2);
		else:
			x = rand.randi_range(x2,x1);
			
		var y = 0;
		var y1 = position.y + ( k * min_dist);
		var y2 = position.y + ( k * max_dist)
		if(y1<y2):
			y = rand.randi_range(y1,y2);
		else:
			y = rand.randi_range(y2,y1);
		
		var type = rand.randi_range(1, types.size())
		spawn(x, y, type);
	pass;
	
func spawn(x, y, type):
	var mob = preload("res://scenes/mobs/Goblin.tscn").instance();
	mob.init(type);
	mob.position = Vector2(x,y);
	get_parent().add_child(mob);
	emit_signal("spawn", mob);
	pass;
	

func _on_DeathAnmiation_animation_finished():
	emit_signal('death', self);
	pass # Replace with function body.
