extends Node2D

var elapsed = 0.0
const MAX_TIME = 64.0
signal score(amount)
export(NodePath) var pickable

func _ready():
	randomize()
	elapsed = randf()
	set_process(true)
	if pickable != null and get_node(pickable) != null:
		get_node(pickable).hide()

func _process(delta):
	elapsed += delta/MAX_TIME
	if elapsed>1.0: 
		elapsed-=1.0
	get_node("float_path/follow").set_unit_offset(elapsed)

func gets_hurt(damage, pos, normal, emitter, travel_time):
	if travel_time > 1.0:
		emit_signal("score", 6)
	else:
		emit_signal("score", 9)
	if pickable != null and get_node(pickable) != null:
		get_node(pickable).set_pos(get_pos())
		get_node(pickable).show()
	queue_free()
