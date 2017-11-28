extends Node2D

export var axis = Vector2()

func _ready():
	get_node("thumbstick").set_pos(Vector2(0.0, 0.0))

func set_deviation(deviation):
	var position = deviation
	if deviation.length() > 64.0:
		position = deviation.normalized() * 64.0
	get_node("thumbstick").set_pos(position)
	axis = position / 64.0