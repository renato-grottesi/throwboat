extends Node2D

var raising = true
var position = Vector2(0,0)
var animating = true
var scale = 0.0

onready var timer = get_node("fade_timer")
onready var sail = get_node("canvas/sail")

signal end()
signal middle()

func _ready():
	position = get_viewport_rect().size / 2.0
	set_process(true)

func _process(delta):
	if animating:
		sail.set_scale(Vector2(scale, scale))
		sail.set_pos(position)
		if raising:
			scale += delta*350.0
		else:
			scale -= delta*350.0
		update()

func _on_fade_timer_timeout():
	if raising:
		raising = false
		timer.stop()
		timer.start()
		emit_signal("middle")
	else:
		sail.set_scale(Vector2(0.0, 0.0))
		update()
		animating = false
		emit_signal("end")
