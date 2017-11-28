extends Area2D

var anim_time = 0.0

enum powers {RANDOM, THOR, LOKI, MAGNET, ORMEN, SHIELD, BEER, HOLE, COUNT}
var strings = ["random", "thor", "loki", "magnet", "ormen", "shield", "beer", "hole"]
var malus =         ["freeze", "invert", "absorb"]
var malus_s_bonus = ["shield", "ormen", "magnet"]

export(int, "RANDOM", "THOR", "LOKI", "MAGNET", "ORMEN", "SHIELD", "BEER", "HOLE") var type = powers.RANDOM

func _ready():
	if type == powers.RANDOM:
		randomize()
		type = 1 + (randi()%(powers.COUNT-1))
	get_node("animation").play(strings[type])
	set_process(true)

func _process(delta):
	anim_time+=delta*2.0
	if anim_time>(2.0*PI): anim_time -= (2.0*PI)

	var scale = 1 + 0.15 * sin(anim_time)
	get_node("animation").set_scale(Vector2(scale, scale))

func _on_pickable_body_enter( body ):
	if(body.has_method("picks")):
		var type_str = strings[type]
		if type_str.begins_with("loki"):
			var idx = randi()%malus.size()
			body.picks(malus[idx])
			body.picks(malus_s_bonus[idx])
		else:
			body.picks(type_str)
		queue_free()
