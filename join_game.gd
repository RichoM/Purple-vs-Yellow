extends Node2D

onready var lobby = $lobby

func _on_join_button_pressed():
	$GUI/join_button.disabled = true
	lobby.game_id = $GUI/game_id.text
	lobby.start()
