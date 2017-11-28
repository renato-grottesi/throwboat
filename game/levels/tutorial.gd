extends "level_base.gd"

var elapsed = 0.0
const MAX_TIME = 20.0

var has_shield = false
var is_done = false
var is_raining = false

func _ready():
	base_setup()
	get_node("hud/story").popup()
	get_node("hud/story").get_ok().set_custom_minimum_size(Vector2(128, 64))
	ship.hide_shield()
	rain.hide()

func _fixed_process(delta):
	if (	!(get_node("hud/story").is_visible()) and 
			!(get_node("hud/shield").is_visible()) and 
			!(get_node("hud/ending").is_visible())):
		advance.set_pos(camera.get_pos() + Vector2(1.0,0.0).rotated(camera.get_rot())*(256.0))
		if advance.overlaps_body(ship):
			elapsed += delta/MAX_TIME
		camera.set_unit_offset(elapsed)
	if elapsed == 0.0: ship.set_pos(Vector2(300.0, -400.0))

func _process(delta):
	camera.get_node("camera").set_enable_follow_smoothing(elapsed!=0.0)
	
	if elapsed > 0.43 and !(has_shield):
		get_node("hud/shield").popup()
		get_node("hud/shield").get_ok().set_custom_minimum_size(Vector2(128, 64))
		has_shield = true
		ship.show_shield()
	
	if elapsed > 0.97 and !(is_done):
		get_node("hud/ending").popup()
		get_node("hud/ending").get_ok().set_custom_minimum_size(Vector2(128, 64))
		is_done = true
	
	get_node("path/follow").set_unit_offset(elapsed)
	get_node("hud/status").update_status(ship.health, score, 0, int(get_node("level_timer").get_time_left()))
	
	ship.shield_angle = input.angle
	ship.vel = input.vel
	
	if(elapsed > 1.0):
		score += int(get_node("level_timer").get_time_left()) * 10
		score += ship.health * 10
		advance_level(1)
	
	if(ship.health < 0):
		quit_to_main_menu()
