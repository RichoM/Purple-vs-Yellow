extends Node

export var host = false
export var game_id = ""
export var player_id = -1

onready var client = Client

signal lobby_joined(game_id)

func _ready():
	init_event_handling()
	if host:
		start()
	
func _process(_delta):
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
	client.start(Globals.server_url, game_id)

func _log(msg):
	print(msg)

func _connected(id):
	_log("Signaling server connected with ID: %d" % id)


func _disconnected():
	_log("Signaling server disconnected: %d - %s" % [client.code, client.reason])


func _lobby_joined(lobby):
	_log("Joined lobby %s" % lobby)
	game_id = lobby
	emit_signal("lobby_joined", game_id)


func _lobby_sealed():
	_log("Lobby has been sealed")
	Globals.level = game_id.hash()
	Globals.player = player_id
	Globals.reset_timestamp()
	get_tree().change_scene("res://game.tscn")

func _mp_connected():
	_log("Multiplayer is connected (I am %d)" % client.rtc_mp.get_unique_id())


func _mp_server_disconnect():
	_log("Multiplayer is disconnected (I am %d)" % client.rtc_mp.get_unique_id())


func _mp_peer_connected(id: int):
	_log("Multiplayer peer %d connected" % id)
	if host:
		client.seal_lobby()


func _mp_peer_disconnected(id: int):
	_log("Multiplayer peer %d disconnected" % id)

