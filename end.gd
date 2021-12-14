extends Node2D

var client = Client
var winner = null
var return_scene = "res://menu.tscn"
onready var p0 = $players/p0
onready var p1 = $players/p1
onready var p0_title = $GUI/purple_wins
onready var p1_title = $GUI/yellow_wins

func _ready():
	if winner == "p0":
		p0.play("alive")
		p1.play("dead")
		p0_title.visible = true
	else:
		p1.play("alive")
		p0.play("dead")
		p1_title.visible = true

func _process(delta):
	if Globals.mode == Globals.ONLINE_MULTIPLAYER:
		# Discard old packets
		client.rtc_mp.poll()
		while client.rtc_mp.get_available_packet_count() > 0:
			var packet = client.rtc_mp.get_packet()
		
		# Send a keep alive packet
		var data = {"t": Globals.get_timestamp()}
		var msg = JSON.print(data)
		if client.rtc_mp.put_packet(msg.to_utf8()) != 0:
			# TODO(Richo): Handle errors
			print("ERROR!")

func _on_play_button_pressed():
	get_tree().change_scene(return_scene)
	get_tree().get_root().remove_child(self)
