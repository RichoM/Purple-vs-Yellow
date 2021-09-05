extends KinematicBody2D

onready var sprite = $sprite
onready var rocket_launcher = $rocket_launcher as RocketLauncher

export var planet_path : NodePath

var planet

var up = Vector2.UP
var vel = Vector2()
var grounded = false
var max_speed = 200

var aiming = false

func _ready():
	planet = get_node(planet_path)

func _process(delta):
	update_up()
	apply_gravity(delta)
	apply_input(delta)
	update_sprite()
	update_gui()
	
func apply_gravity(delta):
	if not grounded:
		vel.y += 20
	
func apply_input(delta):
	if not aiming:
		if grounded and Input.is_action_just_pressed("ui_up"):
			vel.y = -300
			
		if Input.is_action_pressed("ui_right"):
			vel.x += 175
			face_right()
		elif Input.is_action_pressed("ui_left"):
			vel.x -= 175
			face_left()
		else:
			vel.x *= 0.75
		
	if grounded and Input.is_action_just_pressed("ui_accept"):
		if not aiming: 
			rocket_launcher.aim()
			vel.x = 0
		else:
			rocket_launcher.shoot()
		aiming = !aiming
		
	vel.x = clamp(vel.x, -max_speed, max_speed)
	
func face_right():
	sprite.flip_h = false
	rocket_launcher.facing_right = true
	
func face_left():
	sprite.flip_h = true
	rocket_launcher.facing_right = false
	
func update_gui():
	$ground_label.text = str(grounded)
	$vel_label.text = str(vel)
	$up_line.points[1] = up.rotated(-rotation) * 100

func update_up():
	var dir : Vector2 = position - planet.position
	up = dir.normalized()
	
func update_sprite():
	rotation = up.angle() + PI/2
	if grounded:
		if abs(vel.x) > 100:
			sprite.play("walk")
		else:
			sprite.play("idle")
	else:
		sprite.play("jump")
		
func _physics_process(delta):
	var actual_vel = vel.rotated(up.angle() + PI/2)
	$vel_line.points[1] = actual_vel.rotated(-rotation) / 3
	move_and_slide(actual_vel, up, true)
	grounded = false
	for i in get_slide_count():
		if get_slide_collision(i).collider == planet:
			grounded = true
