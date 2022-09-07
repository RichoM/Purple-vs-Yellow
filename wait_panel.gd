extends ColorRect

var icon_angle = 0

func _process(delta):
	icon_angle += PI/2 * delta
	$icon.set_rotation(icon_angle)

func set_game_code(code):
	$msg.text = "Joining game " +  code + "\nPlease wait..."
