extends MarginContainer

onready var expNum = $Bars/LVandEXP/Exp/Bg/Numbers;
onready var expBar = $Bars/LVandEXP/mg/TextureProgress;

onready var lvlNum = $Bars/LVandEXP/Level/Bg/Numbers;

onready var hpNum = $Bars/HP/Count/Bg/Numbers;
onready var hpBar = $Bars/HP/mg/HPbar;

signal swordBtn;
signal rangeBtn;
signal specialBtn;

func _ready():
	var hp = $"../../Player".stats.hp;
	hp_text_change(hp);
	hp_bar_change(hp);
	pass 

func _on_Player_hp_change(hp):
	hp_text_change(hp);
	hp_bar_change(hp);
	pass 
	
func hp_text_change(hp):
	hpNum.text = str(hp) + "/" + str($"../../Player".stats.hp_max);

func hp_bar_change(hp):
	hpBar.value = round((hp * 100) / $"../../Player".stats.hp_max);


func _on_Player_lvl_change(lvl):
	lvlNum.text = str(lvl);
	pass


func _on_Player_exp_change(ex):
	exp_text_change(ex);
	exp_bar_change(ex);
	pass 
	
func exp_text_change(ex):
	expNum.text = str(ex) + "/" + str($"../../Player".stats.next_level);

func exp_bar_change(ex):
	expBar.value = round((ex * 100) / $"../../Player".stats.next_level);


func _on_Player_ranged_on():
	$Bars/LVandEXP/Skills/cnt/Range.disabled = false;


func _on_Player_special_on():
	$Bars/LVandEXP/Skills/cnt/Special.disabled = false;


func _on_Player_he_ded_man(score):
	hp_bar_change(0);
	hp_text_change(0);

func _on_Sword_pressed():
	emit_signal("swordBtn");
	pass
	
func _on_Range_pressed():
	emit_signal("rangeBtn");
	pass
	
func _on_Special_pressed():
	emit_signal("specialBtn");
	pass

func _on_Root_nest_added(val):
	$Bars/LVandEXP/Mobs/cnt/nbg/Nests.text = str(val);
	pass # Replace with function body.


func _on_Root_mob_added(val):
	$Bars/LVandEXP/Mobs/cnt/gbg/Goblins.text = str(val);
	pass # Replace with function body.
