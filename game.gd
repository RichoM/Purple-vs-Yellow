extends Node2D

onready var client = Client
onready var p0 = $player0
onready var p1 = $player1

var game_over = false
var projectiles = []

func _ready():
	Globals.level = Globals.level + 1
	seed(Globals.level)
	for planet in $planets.get_children():
		var sprite = planet.get_node("sprite") as AnimatedSprite
		sprite.frame = rand_range(0, sprite.frames.get_frame_count(sprite.animation) - 1)
		planet.scale = Vector2.ONE * rand_range(1, 4.5)
		
	p0.connect("projectile_shot", self, "_on_projectile_shot")

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
			var msg = packet.get_string_from_utf8()
			var json = JSON.parse(msg).result
			var player_data = json["player"]
			p1.global_position = Vector2(player_data["x"], player_data["y"])
			p1.global_rotation = player_data["r"]
			var projectile_data = json["projectiles"]
			for projectile in projectile_data:
				var new_rocket = preload("res://projectile.tscn").instance() as Projectile
				get_tree().get_current_scene().add_child(new_rocket)
				new_rocket.global_position = Vector2(projectile["x"], projectile["y"])
				new_rocket.velocity = Vector2(projectile["v"]["x"], projectile["v"]["y"])
		
func send_outgoing_messages():
	var player_data = {"x": p0.global_position.x,
						"y": p0.global_position.y,
						"r": p0.global_rotation}
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
