extends "level_base.gd"

onready var thor = get_node("boss/thor")
onready var boss_camera = get_node("camera")

func _ready():
	base_setup()
	get_node("hud/intro").popup()
	get_node("hud/intro").get_ok().set_custom_minimum_size(Vector2(128, 64))

func _process(delta):
	boss_camera.set_enable_follow_smoothing(true)
	get_node("hud/status").update_status(ship.health, score, 0, int(get_node("level_timer").get_time_left()))
	
	ship.shield_angle = input.angle
	ship.vel = input.vel
	
	# kill the clouds if Thor dies before them
	if get_node("boss/thor")==null:
		if get_node("boss/cloud0")!=null:
			get_node("boss/cloud0").gets_hurt(9999, Vector2(0,0), Vector2(0,0), self, 0.1)
		if get_node("boss/cloud0")!=null:
			get_node("boss/cloud0").gets_hurt(9999, Vector2(0,0), Vector2(0,0), self, 0.1)
	
	if(get_node("boss/thor")==null and !get_node("hud/outro").is_visible()):
		get_node("hud/outro").popup()
		get_node("hud/outro").get_ok().set_custom_minimum_size(Vector2(128, 64))
	
	if(ship.health < 0):
		quit_to_main_menu()
	
	if(get_node("boss/thor")!=null):
		boss_camera.set_pos((thor.get_pos() + ship.get_pos())/2.0)
		var zoom = clamp( (thor.get_pos() - ship.get_pos()).length() / 128.0, 1.0, 2.0)
		print(zoom)
		boss_camera.set_zoom(Vector2(zoom, zoom))
	else:
		boss_camera.set_pos(ship.get_pos())
		boss_camera.set_zoom(Vector2(2, 2))

func _on_intro_hide():
	pass

func _on_outro_hide():
	score += int(get_node("level_timer").get_time_left()) * 10
	score += ship.health * 10
	advance_level(5)
