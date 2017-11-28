extends Node2D

onready var level_names = ["tutorial", "level_1", "level_2", "level_3", "final_boss"]
onready var global = get_node("/root/global_status")
onready var confirm_reset = get_node("interface/dialogs/confirm_reset")

func _ready():
	update_map()
	get_node("interface/tutorial").grab_focus()

func update_map():
	for level in range(0,5):
		get_node("interface/"+level_names[level]).set_hidden(level > global.get_max_level())
		get_node("interface/"+level_names[level]+"/hiscore").set_text(str(global.get_hiscore(level)))

func start_level(num):
	if num<=global.get_max_level():
		global.transition_scene_to_level(self, num)

func _on_back_button_down():
	global.transition_scene_to_main_menu(self)

func _on_reset_button_down():
	confirm_reset.popup()
	confirm_reset.get_cancel().grab_focus()
	confirm_reset.get_ok().set_custom_minimum_size(Vector2(64, 32))
	confirm_reset.get_cancel().set_custom_minimum_size(Vector2(64, 32))

func _on_confirm_reset_confirmed():
	global.set_max_level(0)
	global.save_to_file()
	update_map()

func _on_confirm_reset_hide():
	get_node("interface/tutorial").grab_focus()

func _on_tutorial_button_down():
	start_level(0)
func _on_level_1_button_down():
	start_level(1)
func _on_level_2_button_down():
	start_level(2)
func _on_level_3_button_down():
	start_level(3)
func _on_final_boss_button_down():
	start_level(4)
