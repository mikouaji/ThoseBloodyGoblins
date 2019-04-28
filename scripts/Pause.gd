extends MarginContainer



func _on_Continue_pressed():
	hide();
	get_tree().paused = false;


func _on_Quit_pressed():
	get_tree().quit();
