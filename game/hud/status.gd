extends Node2D

func _ready():
	pass

func update_status(health, score, money, time):
	get_node("canvas/health_bar").set_value(health)
	get_node("canvas/score_label").set_text("SCORE: " + str(score))
	get_node("canvas/time_label").set_text("TIME LEFT: " + str(time))
