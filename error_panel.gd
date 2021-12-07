extends Control

onready var label = $msg

signal closed()

func _ready():
	visible = false

func _on_close_button_pressed():
	close()
	
func show_message(msg):
	label.text = msg
	visible = true

func close():
	visible = false
	emit_signal("closed")
