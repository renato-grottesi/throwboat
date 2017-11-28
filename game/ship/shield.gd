extends Node2D

var extra_mjolnir = false
var magnet = false
var absorbing = false
var holing = false

onready var shoot_pos = get_node("shoot_position")
onready var mjolnir_timer = get_node("extra_mjolnir_timer")
onready var magnet_timer = get_node("magnet_timer")
onready var absorb_timer = get_node("absorb_timer")
onready var hole_timer = get_node("hole_timer")

var captured = ""

func _ready():
	shoot_pos.play("empty")
	mjolnir_timer.connect("timeout", self, "_on_extra_mjolnir_timer_timeout")
	magnet_timer.connect("timeout", self, "_on_magnet_timer_timeout")
	absorb_timer.connect("timeout", self, "_on_absorb_timer_timeout")
	hole_timer.connect("timeout", self, "_on_hole_timer_timeout")

func throwback(name, pos, norm):
	if holing:
		# Shoot straight from the black hole
		shoot(name)
		return false;
	if extra_mjolnir:
		var dir1 = norm.rotated(PI + 0.2).normalized()
		var dir2 = norm.rotated(PI - 0.2).normalized()
		var ship = Globals.get("currentShip")
		ship.emit_signal("emit_bullet", "mjolnir", ship, pos+dir1*(-32.0), dir1.angle(), 512.0, 1)
		ship.emit_signal("emit_bullet", "mjolnir", ship, pos+dir2*(-32.0), dir2.angle(), 512.0, 1)
	
	if magnet and captured.empty():
		captured = name
		shoot_pos.play(captured)
		#return false as captured
		return false
	
	if absorbing:
		return false
	
	# return true as bounced
	return true

func extra_mjolnir():
	mjolnir_timer.stop()
	mjolnir_timer.start()
	extra_mjolnir = true

func _on_extra_mjolnir_timer_timeout():
	extra_mjolnir = false

func hole():
	hole_timer.stop()
	hole_timer.start()
	get_node("sprite").play("hole")
	holing = true

func _on_hole_timer_timeout():
	get_node("sprite").play("shield")
	holing = false	

func magnet():
	magnet_timer.stop()
	magnet_timer.start()
	magnet = true

func _on_magnet_timer_timeout():
	magnet = false

func on_release():
	if !captured.empty():
		shoot(captured)
		captured = ""

func shoot(name):
	var ship = Globals.get("currentShip")
	ship.emit_signal("emit_bullet", name, ship, shoot_pos.get_global_pos(), get_parent().get_global_rot(), 512.0, 1)
	shoot_pos.play("empty")

func disable_shield():
	hide()
	set_collision_mask(0)
	set_layer_mask(0)

func enable_shield():
	show()
	set_collision_mask(1)
	set_layer_mask(1)

func absorb():
	absorbing = true
	absorb_timer.stop()
	absorb_timer.start()
	absorbing = true

func _on_absorb_timer_timeout():
	absorbing = false
