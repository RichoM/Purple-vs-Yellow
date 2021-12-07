extends Node2D

onready var client = Client
onready var p0 = $player0
onready var p1 = $player1
onready var debug_label = $GUI/debug_label

var game_over = false
var player = null
var opponent = null

var projectile_counter = 0
var player_projectiles = {} # Projectile -> int (id)
var opponent_projectiles = {} # int (id) -> Projectile 

func _ready():
	if Globals.player == 0:
		player = p0
		opponent = p1
	else:
		player = p1
		opponent = p0
		
	player.is_local = true
	player.input_map = "p"
	player.visible = true
	player.input_enabled = false
	opponent.is_local = false
	opponent.input_map = "p"
	opponent.visible = false
	opponent.input_enabled = false
	
	Globals.level = Globals.level + 1
	seed(Globals.level)
	for planet in $planets.get_children():
		var sprite = planet.get_node("sprite") as AnimatedSprite
		sprite.frame = rand_range(0, sprite.frames.get_frame_count(sprite.animation) - 1)
		planet.scale = Vector2.ONE * rand_range(1, 4.5)
		
	player.connect("projectile_shot", self, "_on_projectile_shot")

func _on_projectile_shot(p):
	if not player_projectiles.has(p):
		projectile_counter += 1
		player_projectiles[p] = projectile_counter
		
		
func _process(delta):
	if Input.is_action_just_pressed("toggle_debug_info"):
		debug_label.visible = !debug_label.visible
	receive_incoming_messages()
	call_deferred("send_outgoing_messages")
	
func receive_incoming_messages():
	client.rtc_mp.poll()
	
	while client.rtc_mp.get_available_packet_count() > 0:
		var packet = null
		packet = client.rtc_mp.get_packet()
		if packet != null:
			player.input_enabled = true
			opponent.visible = true
			var msg = packet.get_string_from_utf8()
			var json = JSON.parse(msg).result
			
			var t_player = Globals.get_timestamp()
			var t_opponent = json["t"]
			var t_diff = t_player - t_opponent
			
			debug_label.text = "%d\n\nPlayer_projectiles: %d\nOpponent_projectiles: %d\n\nP_time: %d\nO_time: %d\nD_time: %d" \
							% [projectile_counter,
								player_projectiles.size(), 
								opponent_projectiles.size(), 
								t_player, 
								t_opponent, 
								t_diff]
			
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
			
			for id in opponent_projectiles.keys():
				if not projectile_data.has(id):
					opponent_projectiles[id].explode()
					opponent_projectiles.erase(id)
					
			for id in projectile_data.keys():
				var p = projectile_data[id]
				var pos = Vector2(p["x"], p["y"])
				var vel = Vector2(p["v"]["x"], p["v"]["y"])
				var exploded = p["exploded"]
				var projectile = null
				
				if opponent_projectiles.has(id):
					projectile = opponent_projectiles[id]
					projectile.global_position = pos
					projectile.velocity = vel
				else:
					projectile = opponent.rocket_launcher.shoot_at(pos, vel)
					opponent_projectiles[id] = projectile
					projectile.is_local = false
				
				if exploded:
					projectile.explode()
					opponent_projectiles.erase(id)
			
				#var t_stop = json["t"]
				#var t_delta = 0.016
				#var t = Globals.get_timestamp()
				#while t < t_stop:
				#	projectile._physics_process(t_delta)
				#	t += t_delta
		
func send_outgoing_messages():
	var player_data = {"x": player.global_position.x,
						"y": player.global_position.y,
						"r": player.global_rotation,
						"facing_right": player.facing_right(),
						"animation": player.sprite.animation,
						"aiming": player.rocket_launcher.rotation if player.aiming else null,
						"dead": player.dead}
	var projectile_data = {}
	for p in player_projectiles.keys():
		var p_id = player_projectiles[p]
		projectile_data[p_id] = {"x": p.global_position.x,
								"y": p.global_position.y,
								"v": {"x": p.velocity.x, "y": p.velocity.y},
								"exploded": p.exploded}
		if p.exploded:
			player_projectiles.erase(p)
			p.explode()
			
	var data = {"t": Globals.get_timestamp(),
				"player": player_data,
				"projectiles": projectile_data}
	var msg = JSON.print(data)
	if client.rtc_mp.put_packet(msg.to_utf8()) != 0:
		# TODO(Richo): Handle errors
		print("ERROR!")

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
	end_scene.winner = winner
	root.add_child(end_scene)

func _on_back_button_pressed():
	get_tree().change_scene("res://menu.tscn")
