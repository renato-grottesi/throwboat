extends Node2D

onready var global = get_node("/root/global_status")

var in_touch_move = false
var in_touch_shield = false

var touch_move_orig = Vector2()
var touch_shield_orig = Vector2()

export var vel = Vector2()
export var angle = 0.0
var ship

var gamepad_invert_left_y = 1.0
var gamepad_invert_right_y = -1.0
var gamepad_deadzone = 0.3

enum Controller { GAMEPAD = 0, KEYMOUSE = 1, TOUCH = 2 }
var controller = Controller.KEYMOUSE

func _ready():
	set_process(true)
	set_process_input(true)
	
	if OS.get_name().begins_with("Android") or OS.get_name().begins_with("iOS"):
		controller = Controller.TOUCH
	else:
		controller = Controller.GAMEPAD
	
	if(global.get_invert_l_y()):
		gamepad_invert_left_y = -1.0
	else:
		gamepad_invert_left_y = 1.0
	if(global.get_invert_r_y()):
		gamepad_invert_right_y = -1.0
	else:
		gamepad_invert_right_y = 1.0
		
	gamepad_deadzone       = global.get_deadzone()

func _process(delta):
	if(in_touch_move):
		get_node("left").set_pos(touch_move_orig)
		get_node("left").show()
	else:
		get_node("left").hide()
	
	if(in_touch_shield):
		get_node("right").set_pos(touch_shield_orig)
		get_node("right").show()
	else:
		get_node("right").hide()

func _input(event):
	if controller != Controller.TOUCH:
		if Input.is_action_pressed("shield_release"):
			ship.on_shield_release()
	
	if event.type == InputEvent.JOYSTICK_BUTTON:
			controller = Controller.GAMEPAD
	elif event.type == InputEvent.KEY and event.is_pressed():
			controller = Controller.KEYMOUSE
	elif event.type == InputEvent.SCREEN_TOUCH:
			controller = Controller.TOUCH
	
	if controller == Controller.TOUCH:
		if event.type == InputEvent.SCREEN_TOUCH:
			var is_move = event.pos.x < get_viewport_rect().size.x / 2.0
			
			if is_move:
				var is_touch_move = event.is_pressed()
				if !in_touch_move and is_touch_move:
					touch_move_orig = event.pos
				in_touch_move = is_touch_move
			else:
				var is_touch_shield = event.is_pressed()
				if !in_touch_shield and is_touch_shield:
					touch_shield_orig = event.pos
				if in_touch_shield and !is_touch_shield:
					ship.on_shield_release()
				in_touch_shield = is_touch_shield
		
		if (!in_touch_move): 
			vel = Vector2(0,0)
			pass
		
		if event.type == InputEvent.SCREEN_DRAG:
			var is_move = event.pos.x < get_viewport_rect().size.x / 2.0
			
			if in_touch_move and is_move:
				var move_vec = event.pos - touch_move_orig
				get_node("left").set_deviation(move_vec)
				vel = get_node("left").axis
			
			if in_touch_shield and !is_move:
				var shield_vec = event.pos - touch_shield_orig
				get_node("right").set_deviation(shield_vec)
				shield_vec = get_node("right").axis
				if shield_vec.length() > 0.1:
					shield_vec.y*=-1.0
					angle = shield_vec.angle()
	
	elif controller == Controller.GAMEPAD:
		if event.type == InputEvent.JOYSTICK_MOTION or event.type == InputEvent.JOYSTICK_BUTTON:
			#TODO: have different configurations for different gamepads
			#vel = Vector2(Input.get_joy_axis(0, JOY_ANALOG_0_Y), Input.get_joy_axis(0, JOY_ANALOG_1_Y))
			#angle = Vector2(Input.get_joy_axis(0, JOY_AXIS_2) , Input.get_joy_axis(0, JOY_AXIS_3)).angle()
			var left_joy = Vector2(Input.get_joy_axis(0, JOY_ANALOG_0_X), Input.get_joy_axis(0, JOY_ANALOG_0_Y) * gamepad_invert_left_y)
			var right_joy = Vector2(Input.get_joy_axis(0, JOY_ANALOG_1_X), Input.get_joy_axis(0, JOY_ANALOG_1_Y) * gamepad_invert_right_y)
			
			if (left_joy.length() > gamepad_deadzone):
				vel = left_joy
			else:
				vel = Vector2(0.0, 0.0)
			
			if (right_joy.length() > gamepad_deadzone):
				angle = right_joy.angle()
			else:
				angle = angle*1.0
	
	elif controller == Controller.KEYMOUSE:
		var ship_pos = ship.get_global_pos()
		var mouse_pos = ship.get_global_mouse_pos()
		
		var s_vec = ship_pos - mouse_pos
		s_vec.x*=-1.0
		angle = s_vec.angle()
		
		var r_l = Input.is_action_pressed("ui_right") - Input.is_action_pressed("ui_left")
		var d_u = Input.is_action_pressed("ui_down") - Input.is_action_pressed("ui_up")
		vel = Vector2(r_l,  d_u).normalized()
