extends KinematicBody2D

var rotation = 0.0

func _ready():
	set_process(true)

func _process(delta):
	rotation+=delta
	if rotation > 2.0 * PI:
		rotation -= 2.0 * PI
	set_rot(rotation)

func throwback(name, pos, norm):
	# return true as bounced
	return true

func disable_shield():
	hide()
	set_collision_mask(0)
	set_layer_mask(0)

func enable_shield():
	show()
	set_collision_mask(1)
	set_layer_mask(1)
