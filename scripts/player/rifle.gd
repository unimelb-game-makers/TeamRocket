extends Node2D

@export var bullet_scene: Resource
@onready var raycast = $RayCast2D

# Inaccuracy value in degrees. Raycast will fire on a random degrees within -inaccuracy to +inaccuracy
@export var MAX_INACCURACY: float = 30.0
@export var INACCURACY_CHANGE_RATE_BASE: float = 0.05
var inaccuracy_limit: float = 0.0:
	set(limit):
		inaccuracy_limit = clamp(limit, 0, MAX_INACCURACY)
var inaccuracy_change_rate: float = INACCURACY_CHANGE_RATE_BASE

@export var MAX_BULLETS = 5
@export var FIRE_RATE = 1.0
@export var RELOAD_SPEED = 0.6

@onready var aiming_line_1 = $AimingUI/Line1
@onready var aiming_line_2 = $AimingUI/Line2
@onready var aiming_curve = $AimingUI

var gun_enabled = true

var bullets = MAX_BULLETS:
	set(bullets_in):
		Globals.player_ui.update_bullets(bullets_in, MAX_BULLETS)
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
		aiming_line_1.rotation_degrees = -inaccuracy_limit
		aiming_line_2.rotation_degrees = inaccuracy_limit
		update_aiming_ui()
		if Input.is_action_just_pressed("fire"):
			if (fire_timer.is_stopped() and reload_timer.is_stopped()):
				raycast.rotation_degrees = randf_range(-inaccuracy_limit, inaccuracy_limit)
				var target = raycast.get_collider()
				if (target):
					print(target)
					if (target is Enemy):
						target.health -= 5
				bullets -= 1
				fire_timer.start()

func _on_reload_timer_timeout() -> void:
	bullets = MAX_BULLETS

func update_aiming_ui() -> void:
	aiming_curve.angle = inaccuracy_limit
	aiming_curve.queue_redraw()
