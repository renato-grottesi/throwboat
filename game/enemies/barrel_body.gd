extends StaticBody2D

func _ready():
	pass

func gets_hurt(damage, pos, normal, emitter, travel_time):
	# forward the collision to the root of the barrel
	get_parent().get_parent().get_parent().gets_hurt(damage, pos, normal, emitter, travel_time)