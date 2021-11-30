extends Node2D

onready var client = Client
onready var p0 = $player0
onready var p1 = $player1

var game_over = false
var projectiles = []
var player = null
var opponent = null

func _ready():
	player = p0 if Globals.player == 0 else p1
	opponent = p1 if Globals.player == 0 else p0
	player.is_local = true
	opponent.is_local = false
	player.player = "p1"
	opponent.player = "p0"
	player.visible = true
	opponent.visible = false
	
	Globals.level = Globals.level + 1
	seed(Globals.level)
	for planet in $planets.get_children():
		var sprite = planet.get_node("sprite") as AnimatedSprite
		sprite.frame = rand_range(0, sprite.frames.get_frame_count(sprite.animation) - 1)
		planet.scale = Vector2.ONE * rand_range(1, 4.5)
		
	player.connect("projectile_shot", self, "_on_projectile_shot")

func _on_projectile_shot(p):
	projectiles.append(p)
		
func _process(delta):
	receive_incoming_messages()
	call_deferred("send_outgoing_messages")
	
func receive_incoming_messages():
	client.rtc_mp.poll()
	
	while client.rtc_mp.get_available_packet_count() > 0:
		var packet = null
		packet = client.rtc_mp.get_packet()
		if packet != null:
			opponent.visible = true
			var msg = packet.get_string_from_utf8()
			var json = JSON.parse(msg).result
			var player_data = json["player"]
			opponent.global_position = Vector2(player_data["x"], player_data["y"])
			opponent.global_rotation = player_data["r"]
			if player_data["facing_right"]:
				opponent.face_right()
			else:
				opponent.face_left()
			opponent.sprite.play(player_data["animation"])
			if player_data["aiming"] != null:
				if not opponent.rocket_launcher.visible:
					opponent.rocket_launcher.rotation = player_data["aiming"]
					opponent.rocket_launcher.visible = true
			else:
				opponent.rocket_launcher.visible = false
			if player_data["dead"] and not opponent.dead:
				opponent.die()
				print("OPPONENT DEAD")
			var projectile_data = json["projectiles"]
			for projectile in projectile_data:
				var new_rocket = preload("res://projectile.tscn").instance() as Projectile
				get_tree().get_current_scene().add_child(new_rocket)
				new_rocket.global_position = Vector2(projectile["x"], projectile["y"])
				new_rocket.velocity = Vector2(projectile["v"]["x"], projectile["v"]["y"])
		
func send_outgoing_messages():
	var player_data = {"x": player.global_position.x,
						"y": player.global_position.y,
						"r": player.global_rotation,
						"facing_right": player.facing_right(),
						"animation": player.sprite.animation,
						"aiming": player.rocket_launcher.rotation if player.aiming else null,
						"dead": player.dead}
	var projectile_data = []
	for projectile in projectiles:
		projectile_data.append({"x": projectile.global_position.x,
								"y": projectile.global_position.y,
								"v": {"x": projectile.velocity.x, "y": projectile.velocity.y}})
	var data = {"t": OS.get_ticks_msec(), # TODO(Richo): Sync timestamp?
				"player": player_data,
				"projectiles": projectile_data}
	var msg = JSON.print(data)
	if client.rtc_mp.put_packet(msg.to_utf8()) != 0:
		# TODO(Richo): Handle errors
		print("ERROR!")
	projectiles.clear()

func _on_player0_tree_exited():
	if game_over: return
	game_over = true
	call_deferred("winner", "p1")

func _on_player1_tree_exited():
	if game_over: return
	game_over = true
	call_deferred("winner", "p0")

func winner(winner):
	var root = get_tree().get_root()

	# Remove the current level
	var level = get_tree().get_current_scene()
	root.remove_child(level)
	level.call_deferred("free")

	# Add end scene
	var end_scene = preload("res://end.tscn").instance()
	var p0 = end_scene.get_node("p0")
	var p1 = end_scene.get_node("p1")
	if winner == "p0":
		p0.play("alive")
		p1.play("dead")
		end_scene.get_node("winner/purple").visible = true
	else:
		p1.play("alive")
		p0.play("dead")
		end_scene.get_node("winner/yellow").visible = true
	
	root.add_child(end_scene)
