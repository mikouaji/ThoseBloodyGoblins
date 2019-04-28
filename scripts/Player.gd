extends KinematicBody2D


export (int) var speed = 330;
export (float) var rotation_speed = 4.5;
var exp_multiplier = 1.65;
var hp_multiplier = 1.25;
var dmg_multiplier = 1.3;

var score = 0;
var kills = 0;

var base_stats = {
	'level' : 1,
	'exp' : 0,
	'next_level' : 30,
	'hp' : 270,
	'hp_max' : 270,
	'dmg' : 30,
	'ranged' : false,
	'ranged_dmg' : 50,
	'ranged_delay' : 5.0,
	'ranged_can' : true,
	'special' : false,
	'special_dmg' : 80,
	'special_delay' : 14.0,
	'special_can' : true,
};

var velocity = Vector2();
var rotation_dir = 0;
var stats = {
	'level' : 1,
	'exp' : 0,
	'next_level' : 30,
	'hp' : 250,
	'hp_max' : 250,
	'dmg' : 30,
	'ranged' : false,
	'ranged_dmg' : 50,
	'ranged_delay' : 5.0,
	'ranged_can' : true,
	'special' : false,
	'special_dmg' : 80,
	'special_delay' : 14.0,
	'special_can' : true,
};

var r_timer = null;
var s_timer = null;

var in_range = [];

signal hp_change;
signal exp_change
signal lvl_change;
signal special_on;
signal ranged_on;
signal score;
signal he_ded_man;

func get_input():
	if Input.is_action_just_pressed("ui_cancel"):
		$"../guis/Pause".show();
		get_tree().paused = true;
	rotation_dir = 0;
	velocity = Vector2();
	if Input.is_action_pressed('ui_right'):
		rotation_dir += 1;
	if Input.is_action_pressed('ui_left'):
		rotation_dir -= 1;
	if Input.is_action_pressed('ui_down'):
		velocity = Vector2(0, speed).rotated(rotation);
	if Input.is_action_pressed('ui_up'):
		velocity = Vector2(0, -speed).rotated(rotation);
	if Input.is_action_just_pressed('ui_select'):
		attack();
	if Input.is_action_just_pressed("spell"):
		attack_ranged();
	if Input.is_action_just_pressed("special"):
		attack_special();

func attack():
	if $AttackAnimation.frame == 10:
		$AttackAnimation.frame = 0;
		$AttackAnimation.play();
		$Swoosh.play();
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			var mob = collision.get_collider();
			if mob != null and mob.is_class("KinematicBody2D"):
				mob.stats.hp -= stats.dmg; 
				$Mele.play();

func attack_ranged():
	if stats.ranged_can and stats.ranged:
		stats.ranged_can = false;
		r_timer = Timer.new();
		add_child(r_timer);
		r_timer.connect("timeout", self, "_on_R_timer_timeout");
		r_timer.set_wait_time(stats.ranged_delay);
		r_timer.set_one_shot(true);
		r_timer.start();
		$Ranged.play();
		$"../guis/GUI/Bars/LVandEXP/Skills/cnt/Range".disabled = true;
		var ball = preload("res://scenes/PlayerSpell.tscn").instance();
		ball.init(stats.ranged_dmg, rotation, position, self);
		get_parent().add_child(ball);
		pass

	 
func _on_R_timer_timeout():
	stats.ranged_can = true;
	$"../guis/GUI/Bars/LVandEXP/Skills/cnt/Range".disabled = false;
	pass
	
func attack_special():
	if stats.special_can and stats.special:
		$SpecialAnimation.frame=0;
		stats.special_can = false;
		s_timer = Timer.new();
		add_child(s_timer);
		s_timer.connect("timeout", self, "_on_S_timer_timeout");
		s_timer.set_wait_time(stats.special_delay);
		s_timer.set_one_shot(true);
		s_timer.start();
		$Special.play();
		$SpecialAnimation.play();
		$"../guis/GUI/Bars/LVandEXP/Skills/cnt/Special".disabled = true;
		for mob in in_range:
			if(mob.position.x > position.x and mob.position.y > position.y):
				mob.position.x += stats.special_dmg * 2.5;
				mob.position.y += stats.special_dmg * 2.5;
			if(mob.position.x > position.x and mob.position.y < position.y):
				mob.position.x += stats.special_dmg * 2.5;
				mob.position.y -= stats.special_dmg * 2.5;
			if(mob.position.x < position.x and mob.position.y < position.y):
				mob.position.x -= stats.special_dmg * 2.5;
				mob.position.y -= stats.special_dmg * 2.5;
			if(mob.position.x < position.x and mob.position.y > position.y):
				mob.position.x -= stats.special_dmg * 2.5;
				mob.position.y += stats.special_dmg * 2.5;
			mob.stats.hp -= stats.special_dmg;
		pass
	
func _on_S_timer_timeout():
	stats.special_can = true;
	$"../guis/GUI/Bars/LVandEXP/Skills/cnt/Special".disabled = false;
	pass

func _on_Goblin_hit(dmg):
	hp_change(dmg * -1);

func _on_Goblin_death(ex):
	kills +=1;
	exp_change(ex.stats.exp);

func _physics_process(delta):
	get_input();
	rotation += rotation_dir * rotation_speed * delta;
	move_and_slide(velocity);

func regen():
	hp_change(stats.hp_max - stats.hp);

func hp_change(val):
	stats.hp += val;
	if(stats.hp <= 0):
		$Death.play();
		emit_signal("he_ded_man", score, kills);
	else:
		emit_signal("hp_change", stats.hp);

func exp_change(val):
	score += val;
	emit_signal("score", score);
	if stats.exp + val >= stats.next_level:
		lvl_change(1);
		stats.exp = 0;
	else:
		stats.exp += val;
	emit_signal("exp_change", stats.exp);
	
func lvl_change(val):
	stats.level += val;
	emit_signal("lvl_change", stats.level);
	$LevelUp.play();
	stats.next_level = round(stats.next_level * exp_multiplier);
	upgrade_hp();
	upgrade_dmg();
	upgrade_special();
	upgrade_ranged();
	if(stats.hp <= round(stats.hp_max * 0.05)):
		regen();
	else:
		get_tree().paused = true;
		$"../guis/LevelUpPopup".show();

func reset_stats():
	stats = base_stats.duplicate(false);
	score = 0;
	kills = 0;
	in_range = [];
	position = Vector2(0,0);

func reset_gui():
	$"../guis/GUI/Bars/LVandEXP/Skills/cnt/Special".disabled = true;
	$"../guis/GUI/Bars/LVandEXP/Skills/cnt/Range".disabled = true;
	emit_signal("hp_change", stats.hp);
	emit_signal("lvl_change", stats.level);
	emit_signal("exp_change", stats.exp);
	pass
	
func upgrade_special():
	stats.special_dmg = round(stats.special_dmg * dmg_multiplier);
	if stats.special_delay > 5:
		stats.special_delay -= 0.2;
	
func upgrade_ranged():	
	stats.ranged_dmg = round(stats.ranged_dmg * dmg_multiplier);
	if stats.ranged_delay > 0.7:
		stats.ranged_delay -= 0.15;
	
func switch_ranged():
	if(!stats.ranged ):
		stats.ranged = !stats.ranged;
		emit_signal("ranged_on");
		
func switch_special():
	if(!stats.special):
		stats.special = !stats.special;
		emit_signal("special_on");
	
func upgrade_dmg():
	stats.dmg = round(stats.dmg * dmg_multiplier);
	
func upgrade_hp():
	stats.hp_max = round(stats.hp_max * hp_multiplier);
	
func pay_the_price():
	hp_change(round(stats.hp_max * 0.1) * -1);

func unpause():
	$"../guis/LevelUpPopup".hide();
	get_tree().paused = false;

func _on_LevelUpPopup_ranged():
	switch_ranged();
	upgrade_ranged();
	pay_the_price();
	unpause();

func _on_LevelUpPopup_regen():
	regen();
	unpause();

func _on_LevelUpPopup_special():
	switch_special();
	upgrade_special();
	pay_the_price();
	unpause();


func _on_LevelUpPopup_sword():
	upgrade_dmg();
	pay_the_price();
	unpause();


func _on_GUI_rangeBtn():
	attack_ranged();


func _on_GUI_specialBtn():
	attack_special();


func _on_GUI_swordBtn():
	attack();


func _on_SpecialRange_body_exited(body):
	if in_range.has(body):
		in_range.remove(in_range.find(body));
	pass


func _on_SpecialRange_body_entered(body):
	if body != self and body.is_class("KinematicBody2D"):
		in_range.append(body);
	pass

func _on_nest_dead(e):
	exp_change(e.stats.exp);