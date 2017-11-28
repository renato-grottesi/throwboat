extends Node2D

var score = 0
onready var global = get_node("/root/global_status")
onready var slime_bullet = preload("res://enemies/slime.tscn")
onready var arrow_bullet = preload("res://enemies/arrow.tscn")
onready var lightning_bullet = preload("res://enemies/lightning.tscn")
onready var hammer_bullet = preload("res://enemies/hammer.tscn")
onready var mjolnir_bullet = preload("res://ship/mjolnir.tscn")
onready var ship = get_node("ship")
onready var input = get_node("hud/input_hud")
onready var camera = get_node("path/follow")
onready var advance = get_node("advance")
onready var rain = get_node("rain")

var camera_stopped = false

func _ready():
	Globals.set("wind", Vector2(0.0, 0.0))
	pass

func base_setup():
	set_process(true)
	set_fixed_process(true)
	input.ship = ship
	for enem in get_node("enemies").get_children():
		enem.connect("emit_bullet", self, "_on_emit_bullet")
		enem.connect("score", self, "_on_score")
	for enem in get_node("boss").get_children():
		enem.connect("emit_bullet", self, "_on_emit_bullet")
		enem.connect("score", self, "_on_score")
	for enem in get_node("whirlpools").get_children():
		enem.set_level(self)
	ship.connect("emit_bullet", self, "_on_emit_bullet")
	rain.hide()

func advance_level(lev):
	global.set_highscore(lev-1, score)
	if lev < 5:
		global.transition_scene_to_level(self, lev)
	else:
		quit_to_main_menu()

func quit_to_main_menu():
	global.transition_scene_to_main_menu(self)

func _on_emit_bullet( name, creator, pos, rot, speed, bounces ):
	var bullet
	if name.begins_with("slime"):
		bullet = slime_bullet.instance()
	if name.begins_with("arrow"):
		bullet = arrow_bullet.instance()
	if name.begins_with("mjolnir"):
		bullet = mjolnir_bullet.instance()
	if name.begins_with("lightning"):
		bullet = lightning_bullet.instance()
	if name.begins_with("hammer"):
		bullet = hammer_bullet.instance()
	bullet.inital_setup(creator, pos, rot, speed, bounces)
	get_node("bullets").add_child(bullet)

func _on_score(amount):
	score+=amount
	
func _on_wind_start_body_enter( body ):
	if body == ship:
		Globals.set("wind", Vector2(0.8, 0.0).rotated(camera.get_rot()))
		rain.show()

func _on_wind_end_body_enter( body ):
	if body == ship:
		Globals.set("wind", Vector2(0.0, 0.0))
		rain.hide()
	