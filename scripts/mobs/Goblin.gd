extends KinematicBody2D

var types = {
	1 : {
		'speed' : 310,
		'hp' : 25,
		'exp' : 4,
		'dmg' : 10,
		'type' : 'mele',
		'sprite' : "res://assets/enemies/goblin-1.png",
	},
	2 : {
		'speed' : 340,
		'hp' : 50,
		'exp' : 20,
		'dmg' : 30,
		'type' : 'mele',
		'sprite' : "res://assets/enemies/goblin-2.png",
	},
	3 : {
		'speed' : 400,
		'hp' : 125,
		'exp' : 75,
		'dmg' : 60,
		'type' : 'mele',
		'sprite' : "res://assets/enemies/goblin-3.png",
	},
	4 : {
		'speed' : 350,
		'hp' : 18,
		'exp' : 6,
		'dmg' : 20,
		'type' : 'ranged',
		'sprite' : "res://assets/enemies/goblin-mage-1.png",
	},
	5 : {
		'speed' : 300,
		'hp' : 40,
		'exp' : 35,
		'dmg' : 60,
		'type' : 'ranged',
		'sprite' : "res://assets/enemies/goblin-mage-2.png",
	},
	6 : {
		'speed' : 280,
		'hp' : 70,
		'exp' : 200,
		'dmg' : 110,
		'type' : 'ranged',
		'sprite' : "res://assets/enemies/goblin-mage-3.png",
	},
};

var stats = {};
var ranged_range = 400;
var velocity = Vector2();	

var mele_attack_time = 4.0;
var attack_timer = null;
var ranged_attack_time = 3.5;
var can_attack = true;

signal hit;
signal death;

func init(type):
	stats = types[type];
	$Sprite.set_texture(load(stats.sprite));

# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("hit", $"../Player", "_on_Goblin_hit");
	self.connect("death", $"../Player", "_on_Goblin_death");
	self.connect("death", $"../../Root", "_on_Goblin_death");
	pass # Replace with function body.

func attack(time):
	can_attack = false;
	attack_timer = Timer.new();
	add_child(attack_timer);
	attack_timer.connect("timeout", self, "_on_Attack_timer_timeout");
	attack_timer.set_wait_time(time);
	attack_timer.set_one_shot(true);
	attack_timer.start();
	emit_signal("hit", stats.dmg);
	$AudioMele.play();
	pass
	
func _on_Attack_timer_timeout():
	can_attack = true;

func spell(time):
	can_attack = false;
	attack_timer = Timer.new();
	add_child(attack_timer);
	attack_timer.connect("timeout", self, "_on_Attack_timer_timeout");
	attack_timer.set_wait_time(time);
	attack_timer.set_one_shot(true);
	attack_timer.start();
	var ball = preload("res://scenes/MobSpell.tscn").instance();
	ball.init(stats.dmg, rotation, position, self);
	ball.connect("hit", self, "_on_Spell_hit");
	get_parent().add_child(ball);
	$AudioRanged.play();
	pass

func _on_Spell_hit(dmg):
	emit_signal("hit", dmg);

func death():
	$AudioDeath.play();
	$DeathAnmiation.frame=0;
	$DeathAnmiation.play();

func _physics_process(delta):
	if stats.hp <= 0:
		if(!$DeathAnmiation.is_playing()):
			death();
	else:
		var player = $"../Player";
		look_at(player.position);
		velocity = Vector2(stats.speed, 0).rotated(rotation);
		if stats.type == 'ranged' and player.position.distance_to(position) < ranged_range:
			velocity = Vector2(0,0);
			if(can_attack):
				spell(ranged_attack_time);
		if stats.type == 'mele':
			for i in get_slide_count():
				var collision = get_slide_collision(i)
				if(collision.collider == player and can_attack):
					attack(mele_attack_time);
		move_and_slide(velocity);
	pass


func _on_DeathAnmiation_animation_finished():
	emit_signal('death', self);
	pass

