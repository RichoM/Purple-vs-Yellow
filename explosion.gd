extends AnimatedSprite

func _ready():
	self.connect("animation_finished", self, "hide")

func _process(delta):
	rotate(delta * 15)
