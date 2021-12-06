extends Node2D

onready var game_id = $GUI/game_id
onready var label = $GUI/label

func _on_lobby_joined(lobby_id):
	$timer.stop()
	game_id.text = Client.lobby
	label.text = "Game code:"

func _on_timer_timeout():
	var count = game_id.text.count(".") % 3
	game_id.clear()
	for i in 3:
		game_id.text += "." if i <= count else " "
