extends KinematicBody2D
class_name Player

onready var sprite = $sprite
onready var planet_range = $range
onready var rocket_launcher = $rocket_launcher as RocketLauncher

export var input_map = "p0"
export var is_local = true
export var input_enabled = true

var planet

var up = Vector2.UP
var vel = Vector2.DOWN * 300
var max_speed = 200

var grounded = false
var aiming = false
var switching_planets = false
var dead = false

signal projectile_shot(projectile)

func _ready():
	if position.x > 0:
		face_left()
	else:
		face_right()

func explode(pos: Vector2):
	if not is_local: return
	vel = Vector2(sign(position.x - pos.x) * 300, -300)
	die()
	
func die():
	dead = true
	rocket_launcher.hide()
	$shape.disabled = true
	$sfx.play()
	yield(get_tree().create_timer(1), "timeout")
	get_parent().remove_child(self)

func _process(delta):
	if not is_local: return
	
	if dead:
		rotate(-5 * delta)
	else:
		find_planet()
		update_up()
		apply_gravity(delta)
		apply_input(delta)
		limit_vel()
		update_sprite()
		update_rotation()
	update_gui()
	
func find_planet():
	for body in planet_range.get_overlapping_bodies():
		if body == planet: continue
		if planet == null or position.distance_to(body.position) < position.distance_to(planet.position):
			# NOTE(Richo): Transform vel to the new planet coordinate system
			var global_vel = vel.rotated(up.angle() + PI/2)
			var new_up = (position - body.position).normalized()
			var new_vel = global_vel.rotated(-(new_up.angle() + PI/2))
			vel = new_vel
			switching_planets = true
			planet = body
	
func apply_gravity(delta):
	if planet and not grounded:
		vel.y += 1500 * delta
	
func apply_input(delta):
	if not input_enabled: return
	if switching_planets or dead: return
	if aiming:
		if Input.is_action_pressed(input_map + "_right"):
			face_right()
		elif Input.is_action_pressed(input_map + "_left"):
			face_left()
			
	if not aiming:
		if Input.is_action_pressed(input_map + "_up"):
			if grounded:
				vel.y = -300
			elif not switching_planets:# and abs(vel.y) < 150:
				vel.y -= 100 #1750 * delta
			
		if Input.is_action_pressed(input_map + "_right"):
			vel.x += 175
			face_right()
		elif Input.is_action_pressed(input_map + "_left"):
			vel.x -= 175
			face_left()
			
	if grounded and Input.is_action_just_pressed(input_map + "_action"):
		if not aiming: 
			rocket_launcher.aim()
			vel.x = 0
		else:
			var projectile = rocket_launcher.shoot()
			emit_signal("projectile_shot", projectile)
		aiming = !aiming

func limit_vel():
	vel.x *= 0.75
	vel.x = clamp(vel.x, -max_speed, max_speed)
	vel.y = clamp(vel.y, -300, 300)
	
func face_right():
	sprite.flip_h = false
	rocket_launcher.facing_right = true
	
func face_left():
	sprite.flip_h = true
	rocket_launcher.facing_right = false
	
func facing_right():
	return rocket_launcher.facing_right
	
func update_gui():
	$ground_label.text = str(grounded)
	$vel_label.text = str(vel)
	$up_line.points[1] = up.rotated(-rotation) * 100

func update_up():
	if planet:
		var dir : Vector2 = position - planet.position
		up = dir.normalized()
	
func update_sprite():
	if grounded:
		if abs(vel.x) > 100:
			sprite.play("walk")
		else:
			sprite.play("idle")
	else:
		sprite.play("jump")

func update_rotation():
	if grounded:
		rotation = up.angle() + PI/2
		
func _physics_process(delta):
	if not is_local: return
	var global_vel = vel.rotated(up.angle() + PI/2)
	$vel_line.points[1] = global_vel.rotated(-rotation) / 3
	move_and_slide(global_vel, up, true)
	grounded = false
	for i in get_slide_count():
		if get_slide_collision(i).collider == planet:
			grounded = true
			switching_planets = false
