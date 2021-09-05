extends Node2D
class_name Projectile

var velocity = Vector2()

onready var line = $Line2D
onready var radius = $range/CollisionShape2D.shape.radius

var attractors_in_range = []

func _process(delta):
	#apply_attractor(get_global_mouse_position(), 10, delta)
	for attractor in attractors_in_range:
		apply_attractor(attractor.position, attractor.scale.x, delta)
		
	line.points[1] = velocity
	position += velocity * delta
	
func apply_attractor(pos: Vector2, strength: float, delta):
	var dir : Vector2 = pos - position
	var length = dir.length()
	dir = dir.normalized()
	dir *= clamp(radius - length, 0, radius) * strength * 0.5
	velocity += dir * delta


func _on_range_body_entered(body):
	attractors_in_range.append(body)


func _on_range_body_exited(body):
	attractors_in_range.erase(body)
