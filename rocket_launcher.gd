extends Node2D
class_name RocketLauncher

var speed = -1.5
var facing_right = true
var aim_limit = PI/3

var rocket = preload("res://Projectile.tscn")

func _ready():
	visible = false

func _process(delta):
	rotate(speed * delta)
	if facing_right:
		scale.x = 1
	else:
		scale.x = -1
	
	if abs(rotation) >= aim_limit:
		speed *= -1
		rotation = aim_limit * sign(rotation)
		
func aim():
	rotation = aim_limit if facing_right else -aim_limit
	visible = true
	
func shoot():
	print(get_global_transform().get_rotation())
	var new_rocket = rocket.instance() as Projectile
	new_rocket.global_transform.origin = global_transform.origin
	new_rocket.velocity = Vector2.ONE.rotated(get_global_transform().get_rotation() - PI/4) * 200
	get_tree().get_root().add_child(new_rocket)
	visible = false
