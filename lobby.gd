extends Node

export var host = false
export var game_id = ""
export var player_id = -1

onready var client = Client

signal lobby_joined(game_id)
signal connection_failed(reason)

func _ready():
	init_event_handling()
	
func _process(_delta):
	# NOTE(Richo): Ignore packets until we start the game
	client.rtc_mp.poll()
	while client.rtc_mp.get_available_packet_count() > 0:
		var packet = client.rtc_mp.get_packet()
	
func init_event_handling():
	client.connect("lobby_joined", self, "_lobby_joined")
	client.connect("lobby_sealed", self, "_lobby_sealed")
	client.connect("disconnected", self, "_disconnected")
	client.rtc_mp.connect("peer_connected", self, "_mp_peer_connected")

func start(retry = 0):
	if Globals.server_url == null:
		yield(get_tree().create_timer(1.0), "timeout")
		if retry < 10: 
			start(retry + 1)
		else:
			get_tree().change_scene("res://menu.tscn")
	else:
		client.start(Globals.server_url + "/webrtc", game_id)
	
func stop():
	client.stop()

func _lobby_joined(lobby):
	print("Joined lobby %s" % lobby)
	game_id = lobby
	emit_signal("lobby_joined", game_id)

func _lobby_sealed():
	print("Lobby has been sealed")
	Globals.level = game_id.hash()
	Globals.player = player_id
	Globals.reset_timestamp()
	get_tree().change_scene("res://game_online.tscn")
	
func _disconnected():
	emit_signal("connection_failed", client.reason)
 
func _mp_peer_connected(id: int):
	print("Multiplayer peer %d connected" % id)
	if host:
		client.seal_lobby()
