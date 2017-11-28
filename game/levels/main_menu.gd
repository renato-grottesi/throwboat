extends Node2D

onready var levels_map = preload("res://levels/levels_map.tscn")
onready var help = get_node("interface/dialogs/help")
onready var credits = get_node("interface/dialogs/credits")

func _ready():
	get_node("interface/play").grab_focus()

func _on_help_button_down():
	help.show()
	help.get_ok().grab_focus()
	help.get_ok().set_custom_minimum_size(Vector2(64, 32))

func _on_options_button_down():
	get_node("interface/dialogs/options").show()
	get_node("interface/dialogs/options/save").grab_focus()

func _on_exit_button_down():
	get_node("/root/global_status").save_to_file()
	get_tree().quit()

func _on_credits_button_down():
	credits.show()
	credits.get_ok().grab_focus()
	credits.get_ok().set_custom_minimum_size(Vector2(64, 32))

func _on_popup_hide():
	get_node("interface/play").grab_focus()

func _on_play_button_down():
	var map = levels_map.instance()
	get_tree().get_root().add_child(map)
	get_tree().get_root().remove_child(self)
	self.queue_free()