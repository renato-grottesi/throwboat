extends "level_base.gd"

var elapsed = 0.0
const MAX_TIME = 60.0

func _ready():
	base_setup()

func _fixed_process(delta):
	advance.set_pos(camera.get_pos() + Vector2(1.0,0.0).rotated(camera.get_rot())*(256.0))
	if advance.overlaps_body(ship) and !camera_stopped:
		elapsed += delta/MAX_TIME
	camera.set_unit_offset(elapsed)

func _process(delta):
	camera.get_node("camera").set_enable_follow_smoothing(elapsed!=0.0)
	
	get_node("hud/status").update_status(ship.health, score, 0, int(get_node("level_timer").get_time_left()))
	
	ship.shield_angle = input.angle
	ship.vel = input.vel
	
	if elapsed > 1.0 and get_node("boss").get_children().size() == 0:
		score += int(get_node("level_timer").get_time_left()) * 10
		score += ship.health * 10
		advance_level(3)
	
	if(ship.health < 0):
		quit_to_main_menu()

func _on_camera_stops_body_enter( body ):
	if body == ship:
		camera_stopped = true

func _on_camera_stops_body_exit( body ):
	if body == ship:
		camera_stopped = false
