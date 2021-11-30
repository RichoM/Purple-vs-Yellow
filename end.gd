extends Node2D

var client = Client

func _process(delta):
	# Discard old packets
	client.rtc_mp.poll()
	while client.rtc_mp.get_available_packet_count() > 0:
		var packet = client.rtc_mp.get_packet()

func _on_play_button_pressed():
	get_tree().change_scene("res://game.tscn")
	get_tree().get_root().remove_child(self)
