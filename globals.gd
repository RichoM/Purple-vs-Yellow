extends Node

var timestamp_begin = 0
var level = 1
var player = null
var server_url = "ws://042c-186-152-147-30.sa.ngrok.io"

func _process(delta):
	if Input.is_action_just_released("mute"):
		AudioServer.set_bus_mute(0, not AudioServer.is_bus_mute(0))

func get_timestamp():
	return OS.get_ticks_msec() - timestamp_begin

func reset_timestamp():
	timestamp_begin = OS.get_ticks_msec()
