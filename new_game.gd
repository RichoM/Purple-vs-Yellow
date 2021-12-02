extends Node2D


func _on_lobby_joined(game_id):
	$game_id.text = Client.lobby
