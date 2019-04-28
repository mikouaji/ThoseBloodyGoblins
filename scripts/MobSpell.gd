extends RigidBody2D

var dmg = 0;
var alive = 3.5;
var speed = 750;
var mage = null;

var timer = null;

signal hit;

func init(val, r, p, m):
	position = p;
	dmg = val;
	rotation = r;
	mage = m;
	add_force(Vector2(0,0), Vector2(speed, 0).rotated(rotation));


func _ready():
	timer = Timer.new();
	add_child(timer);
	timer.connect("timeout", self, "_on_Timer_timeout");
	timer.set_wait_time(alive);
	timer.set_one_shot(true);
	timer.start();

func _on_Timer_timeout():
	queue_free();

func _on_PlayerSpell_body_entered(body):
	if body.is_class("KinematicBody2D") and body != mage:
		emit_signal("hit", dmg);
		queue_free();
	
