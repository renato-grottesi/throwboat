extends StaticBody2D

signal emit_bullet(name, creator, pos, rot, speed, bounces)
signal score(amount)

onready var hit_aid_tween = get_node("hit_aid/tween")
onready var hit_aid_label = get_node("hit_aid/label")
onready var hit_aid = get_node("hit_aid")
onready var dying_tween = get_node("dying_tween")

# Where to target the shoot
enum target_e {
	FIXED,	# Point the shooting at the current body's rotation
	PLAYER,	# Point the shooting at the ship
}

# Pattern of the shooting
enum pattern_e {
	SINGLE,		# Shoot shoot_amount bullets at the target every shoot_delay seconds
	SPREAD,		# Shoot shoot_amount bullets at the target at once with shoot_degree_step between each other
	ROTATION,	# Shoot a bullet every shoot_delay seconds with the body rotating shoot_degree_step after each shoot
	RING,		# Shoot all bullet at once in a ring
}

export(int, "FIXED", "PLAYER") var shoot_target = target_e.FIXED
export(int, "SINGLE", "SPREAD", "ROTATION", "RING") var shoot_pattern = pattern_e.SINGLE
export(int, 0, 64) var shoot_amount = 0
export(int, -360, 360) var shoot_degree_step = 0
export(float, 0.1, 2.0, 0.1)  var shoot_delay = 0.1
export(int, 0, 9999) var health = 5
export(float, 128.0, 512.0, 16.0) var bullet_speed = 300.0
export(int, 1, 999) var bullet_bounces = 1
export(NodePath) var pickable

enum status_e {
	SUBMERGED,		# Underwater, can't be hit in this state
	EMERGING,		# Performing the emerging animation
	SHOOTING,		# Ready to shoot
	SUBMERGING,		# Performing the submerging animation
	DYING,			# Fading away
}
var status = status_e.SUBMERGED
var shoots = 0
var initial_rotation = 0;

onready var animation = get_node("sprite")
onready var timer = get_node("timer")

func _ready():
	initial_rotation = get_rot()
	set_fixed_process(true)
	hit_aid_tween.interpolate_property(hit_aid_label, "rect/scale", Vector2(0.0, 0.0), Vector2(0.75, 0.75), 1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	hit_aid_tween.interpolate_property(hit_aid_label, "rect/pos", Vector2(0.0, 0.0), Vector2(-16.0*0.75, -16.0*0.75), 1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	hit_aid_tween.interpolate_property(hit_aid_label, "visibility/opacity", 1.0, 0.0, 1.0, Tween.TRANS_BACK, Tween.EASE_IN)
	hit_aid_tween.reset_all()
	dying_tween.interpolate_property(animation, "visibility/opacity", 1.0, 0.0, 0.5, Tween.TRANS_SINE, Tween.EASE_IN)
	if pickable != null and get_node(pickable) != null:
		get_node(pickable).hide()

func _fixed_process(delta):
	if status == status_e.SUBMERGED or status == status_e.DYING:
		set_collision_mask(0)
		set_layer_mask(0)
	else: #VISIBLE
		set_collision_mask(1)
		set_layer_mask(1)
	
	if status != status_e.SHOOTING and status != status_e.DYING:
		face_ship()
	
	hit_aid.set_global_rot(0.0)

func face_ship():
	if shoot_target == target_e.PLAYER:
		var enemy = Globals.get("currentShip")
		if(enemy!=null):
			set_rot((get_pos()-enemy.get_pos()).angle())

func _on_timer_timeout():
	_start_emerging()

func gets_hurt(damage, pos, normal, emitter, travel_time):
	var score = damage
	if emitter == self:
		# 5 more points of karma bonus
		score+=5
	if travel_time > 1.0:
		# 7 more points for shoot from far away
		score+=7
	if emitter == self and travel_time > 1.0:
		# super combo bonus
		score+=4
	health-=score
	emit_signal("score", score)
	if health <= 0:
		status = status_e.DYING
		animation.play("dead")
		dying_tween.start()
	hit_aid_label.set_text(str(score))
	hit_aid_tween.resume_all()
	hit_aid_tween.reset_all()
	hit_aid_tween.start()

func _on_visibility_enter_screen():
	_start_emerging()

func _start_emerging():
	status = status_e.EMERGING
	animation.set_frame(0)
	animation.play("emerge")

func _on_sprite_finished():
	if status == status_e.SUBMERGING:
		status = status_e.SUBMERGED
		timer.stop()
		set_rot(initial_rotation)
		if(get_node("visibility").is_on_screen()):
			timer.set_wait_time(shoot_delay)
			timer.start()
	elif status == status_e.EMERGING:
		shoots = 1
		status = status_e.SHOOTING
		animation.set_frame(0)
		animation.play("shoot")
	elif status == status_e.SHOOTING:
		if shoot_pattern != pattern_e.ROTATION:
			face_ship()
		
		if shoot_pattern == pattern_e.SINGLE:
			emit_signal("emit_bullet", "slime", self, get_node("origin").get_global_pos(), get_rot(), bullet_speed, bullet_bounces)
			get_node("sounds").play("shoot")
			shoots+=1
		elif shoot_pattern == pattern_e.SPREAD:
			var angle = get_rot()
			var vec = Vector2(0.0, -24.0)
			emit_signal("emit_bullet", "slime", self, vec.rotated(angle) + get_global_pos(), angle, bullet_speed, bullet_bounces)
			for b in range(1, 1+shoot_amount/2):
				var sub_angle = deg2rad(shoot_degree_step*b)
				emit_signal("emit_bullet", "slime", self, vec.rotated(angle + sub_angle) + get_global_pos(), angle + sub_angle, bullet_speed, bullet_bounces)
				emit_signal("emit_bullet", "slime", self, vec.rotated(angle - sub_angle) + get_global_pos(), angle - sub_angle, bullet_speed, bullet_bounces)
			get_node("sounds").play("shoot")
			shoots+=shoot_amount
		elif shoot_pattern == pattern_e.ROTATION:
			set_rotd(get_rotd() + shoot_degree_step)
			emit_signal("emit_bullet", "slime", self, get_node("origin").get_global_pos(), get_rot(), bullet_speed, bullet_bounces)
			get_node("sounds").play("shoot")
			shoots+=1
		elif shoot_pattern == pattern_e.RING:
			var angle = get_rot()
			var vec = Vector2(0.0, -24.0) #TODO: make it dynamic
			for b in range(0, shoot_amount):
				var sub_angle = deg2rad((360.0/shoot_amount)*b)
				emit_signal("emit_bullet", "slime", self, vec.rotated(angle + sub_angle) + get_global_pos(), angle + sub_angle, bullet_speed, bullet_bounces)
			get_node("sounds").play("shoot")
			shoots+=shoot_amount
		else:
			print("ERROR: draug " + get_name() + "has no shoot pattern set")
		
		if shoots > shoot_amount:
			status = status_e.SUBMERGING
			animation.set_frame(0)
			animation.play("submerge")
		else:
			animation.set_frame(0)
			animation.play("shoot")
	else: #SUBMERGED or DYING
		pass

func _on_dying_complete( object, key ):
	if pickable != null and get_node(pickable) != null:
		get_node(pickable).set_pos(get_pos())
		get_node(pickable).show()
	queue_free()

func _on_tween_tween_complete( object, key ):
	hit_aid_tween.reset_all()
	hit_aid_tween.stop_all()
