extends Area2D

export(float) var unit_offset = 0.0
export(NodePath) var destination
var level setget set_level,get_level

func _ready():
	connect("body_enter", self, "_on_body_enter")

func set_level(val):
	level = val

func get_level():
	return level

func move_camera():
	level.elapsed = unit_offset

func _on_body_enter(body):
	if body.has_method("teleport_to"):
		var dest = get_node(destination)
		body.teleport_to(dest)