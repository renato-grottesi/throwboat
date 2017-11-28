extends KinematicBody2D

var direction = Vector2(0, -1)
var speed = 200.0
const DAMAGE = 10
var teleporting = 0
var is_flying = true

func _ready():
	set_fixed_process(true)

func inital_setup(c, p, r, s, b):
	set_pos(p)
	direction = direction.rotated(r)
	speed = s

func _fixed_process(delta):
	set_rot(direction.angle())
	
	teleporting = int(clamp(teleporting-1, 0, 5))
	
	if(!(get_node("visibility").is_on_screen())):
		queue_free()
	
	if is_flying:
		var motion = direction * delta * speed + Globals.get("wind") * delta;
		motion = move(motion)
		
		if(is_colliding()):
			var target = get_collider()
			
			if(target.has_method("gets_hurt")):
				target.gets_hurt(DAMAGE, get_collision_pos(), get_collision_normal(), self, 0.0)
				destroy()
			elif(target.has_method("throwback")):
				direction = get_collision_normal()
				# throw it some pixels aways from the shield
				set_pos(get_pos() + direction * 16)
			else:
				destroy()
	else: # it is playing the target hit animation
		pass

func destroy():
		is_flying = false
		get_node("sounds").play("hit")
		remove_shape(0)
		get_node("animations").stop()
		get_node("animations").play("hit")
		get_node("animations").connect("finished", self, "terminate")

func terminate():
	queue_free()

func teleport_to(dest):
	if teleporting==0:
		teleporting = 5
		set_pos(dest.get_pos())