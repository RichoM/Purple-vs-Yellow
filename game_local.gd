extends Node2D

onready var client = Client
onready var p0 = $player0
onready var p1 = $player1

var game_over = false
var player = null
var opponent = null

var projectile_counter = 0
var player_projectiles = {} # Projectile -> int (id)

func _ready():
	Globals.mode = Globals.LOCAL_MULTIPLAYER
		
	player = p0
	opponent = p1
		
	player.is_local = true
	player.input_map = "p0"
	player.visible = true
	player.input_enabled = true
	opponent.is_local = true
	opponent.input_map = "p1"
	opponent.visible = true
	opponent.input_enabled = true
	
	for touch_btn in $touch.get_children():
		touch_btn.visible = OS.has_touchscreen_ui_hint()
	
	for planet in $planets.get_children():
		var sprite = planet.get_node("sprite") as AnimatedSprite
		sprite.frame = rand_range(0, sprite.frames.get_frame_count(sprite.animation) - 1)
		planet.scale = Vector2.ONE * rand_range(1, 4.5)
		
	player.connect("projectile_shot", self, "_on_projectile_shot")
	opponent.connect("projectile_shot", self, "_on_projectile_shot")

func _on_projectile_shot(p):
	p.is_local = true
	if not player_projectiles.has(p):
		projectile_counter += 1
		player_projectiles[p] = projectile_counter
		
		
func _process(delta):
	for p in player_projectiles.keys():
		if p.exploded:
			player_projectiles.erase(p)
			p.explode()

func _on_player0_tree_exited():
	if game_over: return
	game_over = true
	call_deferred("winner", "p1")

func _on_player1_tree_exited():
	if game_over: return
	game_over = true
	call_deferred("winner", "p0")

func winner(winner):
	var winner_idx = 0 if winner == "p0" else 1
	Globals.scores[winner_idx] = Globals.scores[winner_idx] + 1
	
	var root = get_tree().get_root()

	# Remove the current level
	var level = get_tree().get_current_scene()
	root.remove_child(level)
	level.call_deferred("free")

	# Add end scene
	var end_scene = preload("res://end.tscn").instance()
	end_scene.winner = winner
	end_scene.return_scene = "res://game_local.tscn"
	root.add_child(end_scene)

func _on_back_button_pressed():
	back()
	
func back():
	get_tree().change_scene("res://menu.tscn")
