extends Node2D

onready var lobby = $lobby
onready var game_id = $GUI/game_id
onready var label = $GUI/label
onready var error_panel = $GUI/error_panel

onready var begin_time = OS.get_ticks_msec()

func _ready():
	lobby.start()

func _on_lobby_joined(lobby_id):
	$timer.stop()
	game_id.text = Client.lobby
	label.text = "Game code:"

func _on_timer_timeout():
	if OS.get_ticks_msec() - begin_time > 20000:
		lobby.stop()
		error_panel.show_message("CONNECTION FAILED!", "Reason: Timeout")
		
	var count = game_id.text.count(".") % 3
	game_id.clear()
	for i in 3:
		game_id.text += "." if i <= count else " "

func _on_lobby_connection_failed(reason):
	if reason.empty(): reason = "Unknown"
	error_panel.show_message("CONNECTION FAILED!", "Reason: %s" % reason)

func _on_back_button_pressed():
	get_tree().change_scene("res://menu.tscn")

func _on_error_panel_closed():
	get_tree().change_scene("res://menu.tscn")
