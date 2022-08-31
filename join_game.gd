extends Node2D

onready var lobby = $lobby
onready var game_id = $GUI/game_id
onready var join_button = $GUI/join_button
onready var error_panel = $GUI/error_panel

# HACK(Richo): We can't handle the textchanged event because the 
# experimental virtual keyboard doesn't support it so instead we
# just check the value on the process event
onready var previous_game_id = game_id.text

func _process(delta):
	if game_id.text != previous_game_id:
		# Only uppercase
		var pos = game_id.caret_position
		game_id.text = game_id.text.to_upper()
		game_id.caret_position = pos
		
		# Enable join button if not empty
		join_button.disabled = game_id.text.strip_edges().empty()
		
		previous_game_id = game_id.text

func _on_join_button_pressed():
	join()

func _on_game_id_text_entered(new_text):
	join()

func join():
	if error_panel.visible: return
	if join_button.disabled: return
	
	var id = game_id.text.strip_edges()
	if id.empty(): return
	
	join_button.disabled = true
	game_id.editable = false
	lobby.game_id = id
	lobby.start()
	
	# If, for some reason, the connection cannot be made we wait 15 seconds
	# before giving up
	yield(get_tree().create_timer(15), "timeout")
	lobby.stop()

func _on_back_button_pressed():
	get_tree().change_scene("res://menu.tscn")

func _on_lobby_connection_failed(reason):
	if reason.empty(): reason = "Unknown"
	error_panel.show_message("CONNECTION FAILED!", "Reason: %s" % reason)

func _on_error_panel_closed():
	get_tree().reload_current_scene()
