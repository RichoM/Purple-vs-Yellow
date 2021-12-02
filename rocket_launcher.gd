extends Node2D
class_name RocketLauncher

export var rocket_speed = 250

var speed = -3
var facing_right = true
var aim_limit = PI/2

var rocket = preload("res://projectile.tscn")

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
	var new_rocket = shoot_at(global_position, Vector2.ONE.rotated(get_global_transform().get_rotation() - PI/4) * rocket_speed)
	new_rocket.position += new_rocket.velocity * 0.016 * 4 # Advance a couple of frames to avoid colliding with player
	return new_rocket
	
func shoot_at(pos, vel):
	var new_rocket = rocket.instance() as Projectile
	get_tree().get_current_scene().add_child(new_rocket)
	new_rocket.global_position = pos
	new_rocket.velocity = vel
	visible = false
	$sfx.play()
	return new_rocket

func hide():
	visible = false
