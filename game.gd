extends Node2D

func _ready():
	pass # Replace with function body.

func _process(delta):
	if Input.is_action_just_released("ui_accept"):
		get_tree().reload_current_scene()
