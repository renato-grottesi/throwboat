extends Node

var max_level    setget set_max_level,    get_max_level
var music_volume setget set_music_volume, get_music_volume
var sound_volume setget set_sound_volume, get_sound_volume
var invert_l_x   setget set_invert_l_x,   get_invert_l_x
var invert_l_y   setget set_invert_l_y,   get_invert_l_y
var invert_r_x   setget set_invert_r_x,   get_invert_r_x
var invert_r_y   setget set_invert_r_y,   get_invert_r_y
var deadzone     setget set_deadzone,     get_deadzone
var hi_scores

onready var main_menu =  preload("res://levels/main_menu.tscn")
onready var shade     =  preload("res://hud/shade.tscn")

onready var tutorial =   preload("res://levels/tutorial.tscn")
onready var level_1 =    preload("res://levels/level_1.tscn")
onready var level_2 =    preload("res://levels/level_2.tscn")
onready var level_3 =    preload("res://levels/level_3.tscn")
onready var final_boss = preload("res://levels/final_boss.tscn")

onready var levels =      [tutorial,   level_1,   level_2,   level_3,   final_boss]
onready var level_names = ["tutorial", "level_1", "level_2", "level_3", "final_boss"]

enum transition_e {BEGIN, MIDDLE, END}
var transition_from
var transition_to
var transition_status = transition_e.END
var shade_scene = null

func _ready():
	Globals.set("wind", Vector2(0.0, 0.0))
	
	# set defaults for new games
	max_level = 0
	music_volume = 0.5
	sound_volume = 0.5
	invert_l_x = false
	invert_l_y = false
	invert_r_x = false
	invert_r_y = true
	deadzone = 0.3
	hi_scores = [0, 0, 0, 0, 0]

	# load from file if it exists
	load_from_file()

func load_from_file():
	var savegame = File.new()
	savegame.open("user://savegame.save", File.READ)
	var currentline = {}
	currentline.parse_json(savegame.get_line())
	if currentline.size():
		max_level =  currentline["max_level"]
		set_music_volume(currentline["music_volume"])
		set_sound_volume(currentline["sound_volume"])
		invert_l_x = currentline["invert_l_x"]
		invert_l_y = currentline["invert_l_y"]
		invert_r_x = currentline["invert_r_x"]
		invert_r_y = currentline["invert_r_y"]
		deadzone = currentline["deadzone"]
		hi_scores = currentline["hi_scores"]
	savegame.close()

func save_to_file():
	var savedict = {
		max_level = max_level,
		music_volume = music_volume,
		sound_volume = sound_volume,
		invert_l_x = invert_l_x,
		invert_l_y = invert_l_y,
		invert_r_x = invert_r_x,
		invert_r_y = invert_r_y,
		deadzone = deadzone,
		hi_scores = hi_scores
	}

	var savegame = File.new()
	savegame.open("user://savegame.save", File.WRITE)
	savegame.store_line(savedict.to_json())
	savegame.close()

func get_max_level():
	return max_level

func set_max_level(new_max_level):
	if new_max_level > max_level:
		max_level = new_max_level

func transition_scene_to_level(scene, level):
	set_max_level(level)
	var level_scene = levels[level].instance()
	do_transition(scene, level_scene)

func transition_scene_to_main_menu(scene):
	var main_menu_instance = main_menu.instance()
	do_transition(scene, main_menu_instance)

func do_transition(s_from, s_to):
	if transition_status == transition_e.END:
		transition_from = s_from
		transition_to = s_to
		shade_scene = shade.instance()
		get_tree().get_root().add_child(shade_scene)
		shade_scene.connect("end", self, "transition_end")
		shade_scene.connect("middle", self, "transition_middle")
		transition_status = transition_e.BEGIN

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST or what == MainLoop.NOTIFICATION_PREDELETE:
		save_to_file()

func transition_end():
	get_tree().get_root().remove_child(shade_scene)
	shade_scene.queue_free()
	transition_status = transition_e.END

func transition_middle():
	get_tree().get_root().remove_child(shade_scene)
	get_tree().get_root().remove_child(transition_from)
	transition_from.queue_free()
	get_tree().get_root().add_child(transition_to)
	get_tree().get_root().add_child(shade_scene)
	transition_status = transition_e.MIDDLE

func set_music_volume(val):
	AudioServer.set_stream_global_volume_scale(val)
	music_volume = val

func get_music_volume():
	return music_volume

func set_sound_volume(val):
	AudioServer.set_fx_global_volume_scale(val)
	sound_volume = val

func get_sound_volume():
	return sound_volume

func set_invert_l_x(val):
	invert_l_x = val

func get_invert_l_x():
	return invert_l_x

func set_invert_l_y(val):
	invert_l_y = val

func get_invert_l_y():
	return invert_l_y

func set_invert_r_x(val):
	invert_r_x = val

func get_invert_r_x():
	return invert_r_x

func set_invert_r_y(val):
	invert_r_y = val

func get_invert_r_y():
	return invert_r_y

func set_deadzone(val):
	deadzone = val

func get_deadzone():
	return deadzone
	
func get_hiscore(level):
	return hi_scores[level]

func set_highscore(level, score):
	if score > hi_scores[level]:
		hi_scores[level] = score