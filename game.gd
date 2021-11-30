extends Node2D

onready var client = Client
var game_over = false

func _ready():
	Globals.level = Globals.level + 1
	seed(Globals.level)
	for planet in $planets.get_children():
		var sprite = planet.get_node("sprite") as AnimatedSprite
		sprite.frame = rand_range(0, sprite.frames.get_frame_count(sprite.animation) - 1)
		planet.scale = Vector2.ONE * rand_range(1, 4.5)
		
func _process(delta):
	# receive incoming messages
	client.rtc_mp.poll()
	while client.rtc_mp.get_available_packet_count() > 0:
		print(client.rtc_mp.get_packet().get_string_from_utf8())
		
	# send outgoing messages
	var msg = str(OS.get_ticks_msec())
	client.rtc_mp.put_packet(msg.to_utf8()) # TODO(Richo): Handle errors

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
