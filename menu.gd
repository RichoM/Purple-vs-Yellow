extends Node2D

var map = {}

func _ready():
	randomize()
	map["p0_up"] = $w
	map["p0_left"] = $a
	map["p0_right"] = $d
	map["p0_action"] = $s
	map["p1_up"] = $up
	map["p1_left"] = $left
	map["p1_right"] = $right
	map["p1_action"] = $down
	
func _on_play_button_pressed():
	get_tree().change_scene("res://game.tscn")

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
