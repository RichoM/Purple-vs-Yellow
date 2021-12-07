extends Node2D

onready var lobby = $lobby
onready var game_id = $GUI/game_id
onready var join_button = $GUI/join_button

func _on_join_button_pressed():
	join()

func _on_game_id_text_entered(new_text):
	join()

func join():
	join_button.disabled = true
	lobby.game_id = game_id.text
	lobby.start()

func _on_game_id_text_changed(new_text):
	var pos = game_id.caret_position
	game_id.text = new_text.to_upper()
	game_id.caret_position = pos
	
