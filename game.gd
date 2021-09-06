extends Node2D

var game_over = false

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
