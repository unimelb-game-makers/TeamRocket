extends Node2D

@export var bullet_scene: Resource
@export var impact_scene: PackedScene
@onready var raycast = $RayCast2D

# Inaccuracy value in degrees. Raycast will fire on a random degrees within -inaccuracy to +inaccuracy
@export var MAX_INACCURACY: float = 30.0

@export var INACCURACY_CHANGE_RATE_BASE: float = 0.05

var inaccuracy: float = 0.0:
	set(limit):
		inaccuracy = clamp(limit, 0, MAX_INACCURACY)
var inaccuracy_change_rate: float = INACCURACY_CHANGE_RATE_BASE

@export var damage = 5

@export var MAX_BULLETS = 5
@export var FIRE_RATE = 1.0
@export var RELOAD_SPEED = 0.6

@onready var aiming_line_1 = $AimingUI/Line1
@onready var aiming_line_2 = $AimingUI/Line2
@onready var aiming_curve = $AimingUI

@onready var fire_effect: AudioStreamPlayer2D = $SoundEffects/FireEffect
@onready var reload_effect: AudioStreamPlayer2D = $SoundEffects/ReloadEffect

# Gun enabled - kitchen vs open world
# Aiming mode - aiming vs not aiming
var gun_enabled = true
var aiming_mode = false

var bullets = MAX_BULLETS:
	set(bullets_in):
		Globals.player_ui.update_bullets(bullets_in, MAX_BULLETS)
		bullets = bullets_in
		if (bullets <= 0):
			reload_effect.play()
			$ReloadTimer.start()

@onready var fire_timer: Timer = $FireTimer
@onready var reload_timer: Timer = $ReloadTimer

func _ready() -> void:
	fire_timer.wait_time = 1.0 / FIRE_RATE
	reload_timer.wait_time = 1.0 / RELOAD_SPEED
	aiming_curve.visible = false

func _process(_delta):
	
	if (gun_enabled):
		look_at(get_global_mouse_position())
	
	if (aiming_mode):
		inaccuracy = lerp(inaccuracy, 0.0, 2.5 * _delta)
		
		aiming_curve.scale.x = remap(inaccuracy, MAX_INACCURACY, 0.0, 1.0, 2.0)
		
		update_aiming_ui()
		aiming_line_1.rotation_degrees = -inaccuracy
		aiming_line_2.rotation_degrees = inaccuracy
		
		if Input.is_action_just_pressed("fire"):
			if (fire_timer.is_stopped() and reload_timer.is_stopped()):
				# Raycast to target
				raycast.rotation_degrees = randf_range(-inaccuracy, inaccuracy)
				var target = raycast.get_collider()
				if (target):
					if (target is Enemy):
						target.health -= damage * (1 + Globals.player_damage_increase)
						
				var hit_location = raycast.get_collision_point()
				var impact = impact_scene.instantiate()
				add_child(impact)
				impact.global_position = hit_location
				
				fire_effect.play(0.3)
				
				bullets -= 1
				fire_timer.start()
				
				# Add inaccuracy
				inaccuracy = MAX_INACCURACY
				
	if Input.is_action_just_pressed("reload"):
		if (reload_timer.is_stopped()):
			reload_effect.play()
			reload_timer.start()

func _on_reload_timer_timeout() -> void:
	bullets = MAX_BULLETS

func update_aiming_ui() -> void:
	aiming_curve.angle = inaccuracy
	aiming_curve.queue_redraw()

func enter_aiming_mode():
	aiming_mode = true
	inaccuracy = MAX_INACCURACY
	
	aiming_curve.visible = true

func exit_aiming_mode():
	aiming_mode = false
	
	aiming_curve.visible = false
