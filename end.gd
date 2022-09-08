extends Node2D

var client = Client
var winner = null
var match_over = false
var return_scene = "res://menu.tscn"
onready var p0 = $players/p0
onready var p1 = $players/p1
onready var p0_title = $GUI/purple_wins
onready var p1_title = $GUI/yellow_wins
onready var scores = $GUI/scores
onready var play_button = $GUI/play_button

func _ready():
	update_ui()
		
func _process(delta):
	if Globals.mode == Globals.ONLINE_MULTIPLAYER:
		# Discard old packets
		client.rtc_mp.poll()
		while client.rtc_mp.get_available_packet_count() > 0:
			var packet = client.rtc_mp.get_packet()
			if packet != null:
				var msg = packet.get_string_from_utf8()
				var json = JSON.parse(msg).result
				# TODO(Richo): Handle score discrepancies!
				
		# Send a keep alive packet
		var data = {"t": Globals.get_timestamp(),
					"scores": Globals.scores}
		var msg = JSON.print(data)
		if client.rtc_mp.put_packet(msg.to_utf8()) != 0:
			# TODO(Richo): Handle errors
			print("ERROR!")
			
func update_ui():
	if winner == "p0":
		p0.play("alive")
		p1.play("dead")
	elif winner == "p1":
		p1.play("alive")
		p0.play("dead")
	else:
		p0.play("dead")
		p1.play("dead")

	scores.text = str(Globals.scores[0]) + " - " + str(Globals.scores[1])
	
	if Globals.scores[0] >= 5:
		p0_title.visible = true
		match_over = true
	elif Globals.scores[1] >= 5:
		p1_title.visible = true
		match_over = true

	if match_over:
		# Move the scores label down to the center
		scores.margin_top = get_viewport().get_visible_rect().size.y/2 - scores.rect_size.y/2
		play_button.text = "REMATCH!"

func _on_play_button_pressed():
	if match_over:
		Globals.scores = [0, 0]
	get_tree().change_scene(return_scene)
	get_tree().get_root().remove_child(self)
