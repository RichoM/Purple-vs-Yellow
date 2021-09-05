extends Node2D
class_name Projectile

var velocity = Vector2()

onready var line = $Line2D
onready var radius = $range/CollisionShape2D.shape.radius

var attractors_in_range = []

func _process(delta):
	#apply_attractor(get_global_mouse_position(), 10, delta)
	for area in attractors_in_range:
		var attractor = area as Attractor
		if attractor:
			apply_attractor(attractor.position, attractor.strength, delta)
		
	line.points[1] = velocity
	position += velocity * delta
	
func apply_attractor(pos: Vector2, strength: float, delta):
	var dir : Vector2 = pos - position
	var length = dir.length()
	dir = dir.normalized()
	dir *= clamp(radius - length, 0, radius) * strength * 0.5
	velocity += dir * delta

func _on_range_area_entered(area):
	attractors_in_range.append(area)

func _on_range_area_exited(area):
	attractors_in_range.erase(area)
