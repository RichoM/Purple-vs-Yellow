extends Node2D

func _on_player0_tree_exited():
	call_deferred("winner", "p1")

func _on_player1_tree_exited():
	call_deferred("winner", "p0")

func winner(winner):
	var end_scene = load("res://end.tscn").instance()
	var p0 = end_scene.get_node("p0")
	var p1 = end_scene.get_node("p1")
	if winner == "p0":
		p0.play("alive")
		p1.play("dead")
	else:
		p1.play("alive")
		p0.play("dead")
	
	add_child(end_scene)
