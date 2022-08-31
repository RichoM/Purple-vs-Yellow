extends Node

enum {LOCAL_MULTIPLAYER, ONLINE_MULTIPLAYER}

var timestamp_begin = 0
var level = 1
var player = null
var server_url = null
var mode = LOCAL_MULTIPLAYER

func _ready():
	#server_url = "ws://localhost:3000"
	fetch_server_url()
	
func fetch_server_url():
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_on_server_url_ready")
	http_request.request("https://richom.github.io/sum.txt")

func _on_server_url_ready(result, response_code, headers, body):
	if response_code != 200: return
	var data = body.get_string_from_utf8()
	server_url = "ws" + data.strip_edges().trim_prefix("http").trim_suffix("/")
	print(server_url)

func _process(delta):
	if Input.is_action_just_released("mute"):
		AudioServer.set_bus_mute(0, not AudioServer.is_bus_mute(0))

func get_timestamp():
	return OS.get_ticks_msec() - timestamp_begin

func reset_timestamp():
	timestamp_begin = OS.get_ticks_msec()
	
func adjust_timestamp(dec):
	timestamp_begin -= dec
