extends Node2D

onready var client = $client

export var url = "ws://192.168.0.230:9080"

var game_started = false

func _ready():
	init_event_handling()
	start()
	
func _process(_delta):
	if game_started:
		var msg = str(OS.get_ticks_msec())
		_log(client.rtc_mp.put_packet(msg.to_utf8()))
	
	client.rtc_mp.poll()
	while client.rtc_mp.get_available_packet_count() > 0:
		_log(client.rtc_mp.get_packet().get_string_from_utf8())
	
func init_event_handling():
	client.connect("lobby_joined", self, "_lobby_joined")
	client.connect("lobby_sealed", self, "_lobby_sealed")
	client.connect("connected", self, "_connected")
	client.connect("disconnected", self, "_disconnected")
	client.rtc_mp.connect("peer_connected", self, "_mp_peer_connected")
	client.rtc_mp.connect("peer_disconnected", self, "_mp_peer_disconnected")
	client.rtc_mp.connect("server_disconnected", self, "_mp_server_disconnect")
	client.rtc_mp.connect("connection_succeeded", self, "_mp_connected")

func start():
	client.start(url, "")

func _log(msg):
	print(msg)

func _connected(id):
	_log("Signaling server connected with ID: %d" % id)


func _disconnected():
	_log("Signaling server disconnected: %d - %s" % [client.code, client.reason])


func _lobby_joined(lobby):
	$game_id.text = lobby
	_log("Joined lobby %s" % lobby)


func _lobby_sealed():
	_log("Lobby has been sealed")


func _mp_connected():
	_log("Multiplayer is connected (I am %d)" % client.rtc_mp.get_unique_id())


func _mp_server_disconnect():
	_log("Multiplayer is disconnected (I am %d)" % client.rtc_mp.get_unique_id())


func _mp_peer_connected(id: int):
	_log("Multiplayer peer %d connected" % id)
	client.seal_lobby()
	game_started = true


func _mp_peer_disconnected(id: int):
	_log("Multiplayer peer %d disconnected" % id)
