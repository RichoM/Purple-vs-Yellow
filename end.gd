extends Node2D

func _on_play_button_pressed():
	get_tree().change_scene("res://player_test.tscn")
	get_tree().get_root().remove_child(self)
