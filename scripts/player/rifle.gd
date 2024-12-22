extends Node2D

@export var bullet_scene: Resource
@onready var raycast = $RayCast2D

# Inaccuracy value in degrees. Raycast will fire on a random degrees within -inaccuracy to +inaccuracy
@export var MAX_INACCURACY: float = 45.0
@export var INACCURACY_CHANGE_RATE_BASE: float = 0.05
var inaccuracy_limit: float = 0.0:
	set(limit):
		inaccuracy_limit = clamp(limit, 0, MAX_INACCURACY)

var inaccuracy_change_rate: float = INACCURACY_CHANGE_RATE_BASE
var inaccuracy: float = 0.0: 
	set(inaccuracy_in):
		if (inaccuracy >= inaccuracy_limit or inaccuracy <= -inaccuracy_limit):
			inaccuracy_change_rate *= -1
			inaccuracy_in = inaccuracy + inaccuracy_change_rate
		inaccuracy = clamp(inaccuracy_in, -inaccuracy_limit, inaccuracy_limit)

@export var MAX_BULLETS = 5
@export var FIRE_RATE = 1.0
@export var RELOAD_SPEED = 0.6

@onready var aiming_line_1 = $AimingUI/Line1
@onready var aiming_line_2 = $AimingUI/Line2

var gun_enabled = true

var bullets = MAX_BULLETS:
	set(bullets_in):
		bullets = bullets_in
		if (bullets <= 0):
			$ReloadTimer.start()

@onready var fire_timer: Timer = $FireTimer
@onready var reload_timer: Timer = $ReloadTimer

func _ready() -> void:
	fire_timer.wait_time = 1.0 / FIRE_RATE
	reload_timer.wait_time = 1.0 / RELOAD_SPEED

func _process(_delta):
	if (gun_enabled):
		look_at(get_global_mouse_position())
		inaccuracy += inaccuracy_change_rate
		aiming_line_1.rotation_degrees = -inaccuracy
		aiming_line_2.rotation_degrees = inaccuracy
		raycast.rotation_degrees = inaccuracy
		if Input.is_action_just_pressed("fire"):
			if (fire_timer.is_stopped() and reload_timer.is_stopped()):
				print("Inaccuracy: " + str(inaccuracy))
				var target_hit = raycast.get_collider()
				if (target_hit):
					print(target_hit)
				bullets -= 1
				fire_timer.start()
				print("Bullets: " + str(bullets))

func _on_reload_timer_timeout() -> void:
	print("Reloaded")
	bullets = MAX_BULLETS
