extends Node2D

onready var lobby = $lobby

func _on_join_button_pressed():
	lobby.game_id = $game_id.text
	lobby.start()
