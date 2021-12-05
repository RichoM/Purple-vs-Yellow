extends Node

var timestamp_begin = 0
var level = 1
var player = null
var server_url = "wss://fathomless-badlands-10412.herokuapp.com"

func _process(delta):
	if Input.is_action_just_released("mute"):
		AudioServer.set_bus_mute(0, not AudioServer.is_bus_mute(0))

func get_timestamp():
	return OS.get_ticks_msec() - timestamp_begin

func reset_timestamp():
	timestamp_begin = OS.get_ticks_msec()
	
func adjust_timestamp(dec):
	timestamp_begin -= dec
