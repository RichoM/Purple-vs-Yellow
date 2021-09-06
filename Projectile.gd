extends Node2D
class_name Projectile

var velocity = Vector2()

onready var explosion_range = $explosion_range
onready var radius = $gravity_range/shape.shape.radius

var attractors_in_range = []

func _process(delta):
	#apply_attractor(get_global_mouse_position(), 10, delta)
	for attractor in attractors_in_range:
		apply_attractor(attractor.position, attractor.scale.x, delta)
		
	$vel_line.points[1] = velocity
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

func _on_collision_range_body_entered(body):
	call_deferred("explode")
	
func explode():
	for body in explosion_range.get_overlapping_bodies():
		body.get_parent().remove_child(body)	
	show_damage()
	get_parent().remove_child(self)
	
func show_damage():    
	var line = explosion_range.get_node("line")
	var origin = line.global_transform.origin
	line.get_parent().remove_child(line)
	get_tree().get_root().add_child(line)
	line.visible = true
	line.global_transform.origin = origin
	line.get_node("sfx").play()
	yield(get_tree().create_timer(1.0), "timeout")
	line.get_parent().remove_child(line)
