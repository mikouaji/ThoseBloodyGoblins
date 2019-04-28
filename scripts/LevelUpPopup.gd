extends MarginContainer

signal regen;
signal sword;
signal ranged;
signal special;

func _process(delta):
	if self.is_visible_in_tree():
		if Input.is_action_just_pressed("regen"):
			emit_signal("regen");
		if Input.is_action_just_pressed("sword"):
			emit_signal("sword");
		if Input.is_action_just_pressed("spell"):
			emit_signal("ranged");
		if Input.is_action_just_pressed("special"):
			emit_signal("special");


func _on_ButtonSpecial_pressed():
	emit_signal("special");


func _on_ButtonRange_pressed():
	emit_signal("ranged");


func _on_ButtonSword_pressed():
	emit_signal("sword");


func _on_ButtonRegen_pressed():
	emit_signal("regen");
