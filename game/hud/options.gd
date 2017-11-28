extends PopupMenu

onready var global     = get_node("/root/global_status")
onready var sound      = get_node("sound_volume")
onready var music      = get_node("music_volume")
onready var invert_l_x = get_node("invert_l_x")
onready var invert_l_y = get_node("invert_l_y")
onready var invert_r_x = get_node("invert_r_x")
onready var invert_r_y = get_node("invert_r_y")

func _ready():
	sound.set_value(global.get_sound_volume())
	music.set_value(global.get_music_volume())
	invert_l_x.set_pressed(global.get_invert_l_x())
	invert_l_y.set_pressed(global.get_invert_l_y())
	invert_r_x.set_pressed(global.get_invert_r_x())
	invert_r_y.set_pressed(global.get_invert_r_y())
	get_node("save").grab_focus()

func _on_save_button_down():
	global.save_to_file()
	hide()

func _on_music_volume_value_changed( value ):
	global.set_music_volume(value)

func _on_sound_volume_value_changed( value ):
	global.set_sound_volume(value)

func _on_invert_l_x_toggled( pressed ):
	global.set_invert_l_x(pressed)

func _on_invert_l_y_toggled( pressed ):
	global.set_invert_l_y(pressed)

func _on_invert_r_x_toggled( pressed ):
	global.set_invert_r_x(pressed)

func _on_invert_r_y_toggled( pressed ):
	global.set_invert_r_y(pressed)
