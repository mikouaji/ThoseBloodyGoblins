extends MarginContainer

signal start;

func _on_Quit_pressed():
	get_tree().quit();


func _on_Start_pressed():
	emit_signal('start');
