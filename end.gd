extends Node2D

var client = Client
var winner = null
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
	# Discard old packets
	client.rtc_mp.poll()
	while client.rtc_mp.get_available_packet_count() > 0:
		var packet = client.rtc_mp.get_packet()

func _on_play_button_pressed():
	get_tree().change_scene("res://game.tscn")
	get_tree().get_root().remove_child(self)
