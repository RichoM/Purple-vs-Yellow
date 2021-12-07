extends Node2D

onready var lobby = $lobby
onready var game_id = $GUI/game_id
onready var join_button = $GUI/join_button
onready var error_panel = $GUI/error_panel

func _on_join_button_pressed():
	join()

func _on_game_id_text_entered(new_text):
	join()

func join():
	if game_id.text.empty(): return
	
	join_button.disabled = true
	game_id.editable = false
	lobby.game_id = game_id.text
	lobby.start()

func _on_game_id_text_changed(new_text):	
	# Only uppercase
	var pos = game_id.caret_position
	game_id.text = new_text.to_upper()
	game_id.caret_position = pos
	
	# Enable join button if not empty
	join_button.disabled = game_id.text.empty()

func _on_back_button_pressed():
	get_tree().change_scene("res://menu.tscn")

func _on_lobby_connection_failed(reason):
	error_panel.show_message("CONNECTION FAILED!\nReason: %s" % reason)

func _on_error_panel_closed():
	get_tree().reload_current_scene()
