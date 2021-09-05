extends KinematicBody2D

var velocity = Vector2()
var on_floor = false

onready var sprite = $PlayerSprite

func _process(delta):
	handleInput()
	addGravity()

func handleInput():
	if Input.is_action_pressed("ui_left"):
		velocity.x = -50
		sprite.flip_h = true
	elif Input.is_action_pressed("ui_right"):
		velocity.x = 50
		sprite.flip_h = false
	else:
		velocity.x = 0
		
	if on_floor and Input.is_action_just_pressed("ui_up"):
		velocity.y = -100
		
func addGravity():
	if velocity.y > 0:
		velocity += Vector2.DOWN * 3
	else:
		velocity += Vector2.DOWN * 5
		
func applyAnimation():
	if on_floor:
		if abs(velocity.x) > 1:
			sprite.play("walk")
		else:
			sprite.play("idle")
	else:
		sprite.play("jump")

func _physics_process(delta):
	move_and_slide(velocity, Vector2.UP, true)
	on_floor = is_on_floor()
	applyAnimation()

