extends KinematicBody2D

var direction = Vector2(0, -1)
const DAMAGE = 5
var speed = 300.0
var bounces = 1
var creator
var is_flying = true
var creation_ms
var processed = false # hack to prevent processing before setting the visibility detector
var teleporting = 0

func _ready():
	set_fixed_process(true)

func inital_setup(c, p, r, s, b):
	creator = c
	set_pos(p)
	direction = direction.rotated(r)
	creation_ms = OS.get_ticks_msec()
	speed = s
	bounces = b

func _fixed_process(delta):
	set_rot(direction.angle())
	
	teleporting = int(clamp(teleporting-1, 0, 5))
	
	if(processed and !(get_node("visibility").is_on_screen())):
		queue_free()
	processed = true
	
	if is_flying:
		var motion = direction * delta * speed + Globals.get("wind") * delta;
		motion = move(motion)
		
		if(is_colliding()):
			var target = get_collider()
			var normal = get_collision_normal()
			
			if(target.has_method("gets_hurt")):
				var travel_time = (OS.get_ticks_msec() - creation_ms)/1000.0
				target.gets_hurt(DAMAGE, get_collision_pos(), normal, creator, travel_time)
				decrease_bounces(motion, normal)
			elif(target.has_method("throwback")):
				bounce(motion, normal)
				if(target.has_method("get_speed")):
					var target_speed = target.get_speed()
					speed+=target_speed
				# remove if captured
				if !target.throwback(get_node("name").get_text(), get_pos(), direction):
					queue_free()
			else:
				decrease_bounces(motion, normal)
	else: # it is playing the target hit animation
		pass

func decrease_bounces(motion, normal):
	bounces = bounces-1
	if bounces <=0:
		destroy()
	else:
		bounce(motion, normal)

func bounce(motion, normal):
	move(normal.reflect(motion))
	direction = normal.reflect(direction)

func destroy():
		is_flying = false
		get_node("sounds").play("hit")
		remove_shape(0)
		var animations = get_node("animations")
		animations.stop()
		animations.play("hit")
		animations.connect("finished", self, "terminate")

func terminate():
	queue_free()

func teleport_to(dest):
	if teleporting==0:
		teleporting = 5
		set_pos(dest.get_pos())
