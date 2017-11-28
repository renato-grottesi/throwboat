extends KinematicBody2D

const MAX_VEL = 200.0
const INERTIA_ROT = 0.15
const INERTIA_VEL = 0.10

export var max_health = 100
export var vel = Vector2(0,0)
export var shield_angle = 0
export var health = 0

onready var shield = get_node("shield/body")
onready var shield_extra = get_node("shield_extra/body")
onready var ormen_shield = get_node("ormen_shield")
onready var explosion = get_node("explosion")
onready var hit_aid_tween = get_node("hit_aid/tween")
onready var hit_aid_label = get_node("hit_aid/label")
onready var hit_aid = get_node("hit_aid")
onready var teleport_tween_begin = get_node("teleport_tween_begin")
onready var teleport_tween_end = get_node("teleport_tween_end")

signal emit_bullet(name, creator, pos, rot, speed, bounces)

var shield_frozen = false
var invert = false
var invincible = false
var old_vel = Vector2(0.0, 0.0)
var teleporting = false
var teleport_dest

func _ready():
	Globals.set("currentShip", self)
	set_process(true)
	explosion.hide()
	_on_extra_shield_timer_timeout()
	_on_ormen_shield_timer_timeout()
	add_collision_exception_with(ormen_shield)
	add_collision_exception_with(shield)
	add_collision_exception_with(shield_extra)
	health = max_health
	hit_aid_tween.interpolate_property(hit_aid_label, "rect/scale", Vector2(0.0, 0.0), Vector2(0.75, 0.75), 2.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	hit_aid_tween.interpolate_property(hit_aid_label, "rect/pos", Vector2(0.0, 0.0), Vector2(-16.0*0.75, -16.0*0.75), 2.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	hit_aid_tween.interpolate_property(hit_aid_label, "visibility/opacity", 1.0, 0.0, 2.0, Tween.TRANS_BACK, Tween.EASE_IN)
	for elem in range (0, 15):
		hit_aid_tween.interpolate_property(get_node("body"), "visibility/opacity", float(!elem%2), float(elem%2), 1.0/8.0, Tween.TRANS_BACK, Tween.EASE_IN, elem*1.0/8.0)
		hit_aid_tween.interpolate_property(get_node("sail"), "visibility/opacity", float(!elem%2), float(elem%2), 1.0/8.0, Tween.TRANS_BACK, Tween.EASE_IN, elem*1.0/8.0)
	hit_aid_tween.reset_all()

func _process(delta):
	if teleporting: return
	
	var view_rect_half = (get_viewport_rect().size / get_canvas_transform().get_scale()) / 2.0
	var view_pos = (get_viewport_transform().get_origin() - view_rect_half) * -1.0
	
	var wind = Globals.get("wind")
	
	vel += wind
	if(vel.length()>0.0): 
		# Angles are between -PI to PI, so sum 2PI to make them positive and simplify the math
		var current = get_rot() + 2 * PI
		var target  = vel.angle() + 2 * PI
		# Now make sure that the ship always rotate to the closest 180 turn instead of doing 360s
		if current - target < -PI:
			target -= 2.0*PI
		if current - target > PI:
			target += 2.0*PI
		# Finally do some sort of linear interpolation to make the transition from current to target
		target = (1.0-(delta/INERTIA_ROT))*current + (delta/INERTIA_ROT)*target
		set_rot(target)
	
	if invert:
		vel = vel * Vector2(-1.0, -1.0)
	
	get_node("water_splash").set_emitting(vel.length()>0.0)
	
	vel = (1.0-(delta/INERTIA_VEL))*old_vel + (delta/INERTIA_VEL)*vel
	old_vel = vel
	
	var motion = vel * MAX_VEL * delta
	motion = move( motion )
	
	if (is_colliding()):
		var target = get_collider()
		
		if(target.has_method("gets_hurt") and !invincible):
			target.gets_hurt(20, get_collision_pos(), get_collision_normal(), self, 0.0)
			gets_hurt(20, get_collision_pos(), get_collision_normal(), self, 0.0)
		
		var n = get_collision_normal()
		motion = n.slide(motion)
		move(motion)
		
	if !shield_frozen:
		var angle = shield_angle + get_rot()
		get_node("shield").set_rot(-angle)
		get_node("shield_extra").set_rot(-angle - PI)
	
	# stay in the camera bounds
	if(get_pos().x<(view_pos.x-view_rect_half.x)):
		set_pos(Vector2(view_pos.x-view_rect_half.x,get_pos().y))
	if(get_pos().x>(view_pos.x+view_rect_half.x)):
		set_pos(Vector2(view_pos.x+view_rect_half.x,get_pos().y))
	if(get_pos().y<(view_pos.y-view_rect_half.y)):
		set_pos(Vector2(get_pos().x,view_pos.y-view_rect_half.y))
	if(get_pos().y>(view_pos.y+view_rect_half.y)):
		set_pos(Vector2(get_pos().x,view_pos.y+view_rect_half.y))
	
	var sail = get_node("sail")
	if(wind.length()==0.0):
		sail.play("reefed")
	else:
		sail.play("sail")
		sail.set_global_rot(wind.angle())
		# TODO: fix the clamping for vertical sections
		#var sail_rot = sail.get_rot() + PI*4.0
		#var MAX_SAIL_ROT = PI/6.0
		#sail.set_rot(clamp(sail_rot, PI*4.0-MAX_SAIL_ROT, PI*4.0+MAX_SAIL_ROT))
	
	hit_aid.set_global_rot(0.0)

func gets_hurt(amount, pos, normal, emitter, travel_time):
	if !invincible:
		explosion.set_global_pos(pos)
		explosion.set_global_rot((normal.rotated(PI)).angle())
		explosion.show()
		explosion.set_frame(0)
		explosion.play("explode")
		health-=amount
		if Input.get_connected_joysticks().size() != 0:
			Input.start_joy_vibration(0, 0.5, 0.5, 0.1)
		hit_aid_label.set_text(str(amount))
		hit_aid_tween.resume_all()
		hit_aid_tween.start()
		invincible = true

func get_speed():
	return vel.length() * MAX_VEL

func _on_explosion_finished():
	explosion.stop()
	explosion.hide()

func hide_shield():
	shield.disable_shield()

func show_shield():
	shield.enable_shield()

func picks(what):
	if what.begins_with("freeze"):
		shield_frozen = true
		get_node("shield_frozen_timer").stop()
		get_node("shield_frozen_timer").start()
	elif what.begins_with("invert"):
		invert = true
		get_node("invert_timer").stop()
		get_node("invert_timer").start()
	elif what.begins_with("absorb"):
		shield.absorb()
		shield_extra.absorb()
	elif what.begins_with("thor"):
		shield.extra_mjolnir()
		shield_extra.extra_mjolnir()
	elif what.begins_with("magnet"):
		shield.magnet()
		shield_extra.magnet()
	elif what.begins_with("hole"):
		shield.hole()
		shield_extra.hole()
	elif what.begins_with("ormen"):
		get_node("ormen_shield_timer").stop()
		get_node("ormen_shield_timer").start()
		ormen_shield.enable_shield()
		_on_extra_shield_timer_timeout()
		hide_shield()
	elif what.begins_with("shield"):
		shield_extra.enable_shield()
		get_node("extra_shield_timer").stop()
		get_node("extra_shield_timer").start()
	elif what.begins_with("beer"):
		health+=50
		if health > max_health:
			health = max_health

func _on_shield_frozen_timer_timeout():
	shield_frozen = false

func on_shield_release():
	shield.on_release()
	shield_extra.on_release()

func _on_extra_shield_timer_timeout():
	shield_extra.disable_shield()

func _on_ormen_shield_timer_timeout():
	ormen_shield.disable_shield()
	show_shield()

func _on_invert_timer_timeout():
	invert = false

func _on_hit_aid_tween_complete( object, key ):
	if(object!=get_node("body") and object!=get_node("sail")):
		hit_aid_tween.reset_all()
		hit_aid_tween.stop_all()
		invincible = false

func teleport_to(dest):
	if !teleporting:
		teleporting = true
		teleport_dest = dest
		teleport_tween_begin.remove_all()
		teleport_tween_begin.interpolate_property(self, "transform/scale", Vector2(1,1), Vector2(0,0), 0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		#teleport_tween_begin.interpolate_property(self, "transform/rot", get_rot(), get_rot()+5.0*PI, 0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		teleport_tween_begin.resume_all()
		teleport_tween_begin.start()

func _on_teleport_tween_begin_tween_complete( object, key ):
	teleport_tween_begin.stop_all()
	set_pos(teleport_dest.get_pos())
	teleport_dest.move_camera()
	teleport_tween_end.remove_all()
	teleport_tween_end.interpolate_property(self, "transform/scale", Vector2(0,0), Vector2(1,1), 0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	#teleport_tween_end.interpolate_property(self, "transform/rot", get_rot(), get_rot()+5.0*PI, 0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	teleport_tween_end.resume_all()
	teleport_tween_end.start()

func _on_teleport_tween_end_tween_complete( object, key ):
	teleporting = false
	teleport_tween_end.stop_all()
