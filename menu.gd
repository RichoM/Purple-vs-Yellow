extends Node2D

var map = {}

func _ready():
	randomize()
	map["p0_up"] = $static/p0/w
	map["p0_left"] = $static/p0/a
	map["p0_right"] = $static/p0/d
	map["p0_action"] = $static/p0/s
	map["p1_up"] = $static/p1/up
	map["p1_left"] = $static/p1/left
	map["p1_right"] = $static/p1/right
	map["p1_action"] = $static/p1/down
	Globals.scores = [0, 0]

func _process(_delta):
	for key in map.keys():
		var sprite = map[key] as AnimatedSprite
		if Input.is_action_just_pressed(key):
			var frame = sprite.frame
			sprite.animation = "pressed"
			sprite.frame = frame
		elif Input.is_action_just_released(key):
			var frame = sprite.frame
			sprite.animation = "released"
			sprite.frame = frame

func _on_new_game_button_pressed():
	get_tree().change_scene("res://new_game.tscn")

func _on_join_game_button_pressed():
	get_tree().change_scene("res://join_game.tscn")

func _on_local_multiplayer_button_pressed():
	get_tree().change_scene("res://game_local.tscn")

func _on_online_multiplayer_button_pressed():
	$GUI/level_0.visible = false
	$GUI/level_1.visible = true

func _on_back_button_pressed():
	$GUI/level_0.visible = true
	$GUI/level_1.visible = false

func _on_quit_button_pressed():
	get_tree().quit()
