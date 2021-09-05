extends Node2D

func _process(delta):
	if Input.is_action_just_released("ui_accept"):
		get_tree().change_scene("res://player_test.tscn")
