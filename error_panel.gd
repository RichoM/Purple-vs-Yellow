extends Control

onready var label = $msg

signal closed()

func _ready():
	visible = false

func _on_close_button_pressed():
	close()
	
func show_message(title, msg = ""):
	label.text = title
	if not msg.empty(): label.text += "\n" + msg
	visible = true

func close():
	visible = false
	emit_signal("closed")
