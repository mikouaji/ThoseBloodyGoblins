extends MarginContainer

func set_score(score):
	$cnt/mg/Info/Score.text = "Your score: " + str(score);

func set_kills(score):
	$cnt/mg/Info/Killed.text = "Goblins killed " + str(score);

func set_high_score(score):
	$cnt/mg/Info/HighScore.text = "High score: " + str(score);

signal new_game;

func _on_Quit_pressed():
	get_tree().quit();


func _on_PlayAgain_pressed():
	emit_signal("new_game");
