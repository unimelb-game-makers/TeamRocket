extends Node2D

signal fired

@export var max_inaccuracy: float = 30.0
@export var inaccuracy_change_rate_base: float = 0.05
@export var bullet_scene: Resource
@export var impact_scene: PackedScene
@export var max_bullets = 5
@export var fire_rate = 1.0
@export var reload_speed = 0.6

@onready var raycast = $RayCast2D
@onready var muzzle_flash: Light2D = $MuzzleFlash
@onready var aiming_line_1 = $AimingUI/Line1
@onready var aiming_line_2 = $AimingUI/Line2
@onready var aiming_curve = $AimingUI

@onready var fire_effect: AudioStreamPlayer2D = $SoundEffects/FireEffect
@onready var reload_effect: AudioStreamPlayer2D = $SoundEffects/ReloadEffect
# Inaccuracy value in degrees. Raycast will fire on a random degrees within -inaccuracy to +inaccuracy


var inaccuracy: float = 0.0:
	set(limit):
		inaccuracy = clamp(limit, 0, max_inaccuracy)
var inaccuracy_change_rate: float = inaccuracy_change_rate_base


# Gun enabled - kitchen vs open world
# Aiming mode - aiming vs not aiming
var gun_enabled = true
var aiming_mode = false

var bullets = max_bullets:
	set(bullets_in):
		Globals.player_ui.update_bullets(bullets_in, max_bullets)
		bullets = bullets_in
		if (bullets <= 0):
			reload_effect.play()
			$ReloadTimer.start()

@onready var fire_timer: Timer = $FireTimer
@onready var reload_timer: Timer = $ReloadTimer

func _ready() -> void:
	fire_timer.wait_time = 1.0 / fire_rate
	reload_timer.wait_time = 1.0 / reload_speed
	aiming_curve.visible = false
	muzzle_flash.visible = false

func _process(_delta):
	if (gun_enabled):
		look_at(get_global_mouse_position())
	
	if (aiming_mode):
		inaccuracy = lerp(inaccuracy, 0.0, 2.5 * _delta)
		
		aiming_curve.scale.x = remap(inaccuracy, max_inaccuracy, 0.0, 1.0, 2.0)
		
		update_aiming_ui()
		aiming_line_1.rotation_degrees = - inaccuracy
		aiming_line_2.rotation_degrees = inaccuracy

func reload():
	if (reload_timer.is_stopped() and bullets < max_bullets):
		reload_effect.play()
		reload_timer.start()

func fire(damage) -> void:
	if (fire_timer.is_stopped() and reload_timer.is_stopped()):
		# Raycast to target
		raycast.rotation_degrees = randf_range(-inaccuracy, inaccuracy)
		var target = raycast.get_collider()
		if (target):
			if (target is EnemyHitbox):
				target.damage(damage)
				
		var hit_location = raycast.get_collision_point()
		var impact = impact_scene.instantiate()
		add_child(impact)
		impact.global_position = hit_location
		
		fire_effect.play(0.3)
		fired.emit()
		
		bullets -= 1
		fire_timer.start()
		
		# Add inaccuracy
		inaccuracy = max_inaccuracy

		create_muzzle_flash()

func _on_reload_timer_timeout() -> void:
	bullets = max_bullets

func update_aiming_ui() -> void:
	aiming_curve.angle = inaccuracy
	aiming_curve.queue_redraw()

func enter_aiming_mode():
	aiming_mode = true
	inaccuracy = max_inaccuracy
	
	aiming_curve.visible = true

func exit_aiming_mode():
	aiming_mode = false
	
	aiming_curve.visible = false


func create_muzzle_flash():
	muzzle_flash.visible = true
	muzzle_flash.energy = 2.0
	var tween = create_tween()
	tween.tween_property(muzzle_flash, "energy", 0, 0.2)
