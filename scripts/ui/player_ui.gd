extends Control
class_name PlayerUI

@onready var health_bar: TextureProgressBar = $HealthBar
@onready var gun_texture: TextureRect = $GunInfo/GunTexture
@onready var ammo_count: Label = $GunInfo/AmmoCount
@onready var timer: Label = $TimerProgressBar/Timer
@onready var timer_progress_bar: TextureProgressBar = $TimerProgressBar
@onready var vignette_shader: ColorRect = $VignetteShader

var vignette_alpha = 0.7
var vignette_fade_speed = 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.player_ui = self
	await get_tree().process_frame
	await get_tree().process_frame
	update_health(Globals.player_stats.health, Globals.player_stats.max_health)
	vignette_shader.material.set_shader_parameter("alpha", 0)


func _process(delta: float) -> void:
	if vignette_alpha > 0:
		vignette_alpha = vignette_alpha - vignette_fade_speed * delta
		vignette_shader.material.set_shader_parameter("alpha", vignette_alpha)


func update_health(health, max_health):
	health_bar.value = health
	health_bar.max_value = max_health

func update_bullets(bullets, max_bullets):
	ammo_count.text = str(bullets) + "/" + str(max_bullets)

func update_time(time):
	timer.text = "%02d:%02d" % [time / 60, time % 60]
	timer_progress_bar.value = 1440 - time

func play_damaged_effect(damaged_amount: int):
	var time_scale = 0.4
	var slow_time_duration = 0.25
	vignette_alpha = 0.8
	# If player lose more than 25% HP, show a stronger effect
	if damaged_amount >= Globals.player_stats.max_health * 0.25:
		time_scale = 0.2
		slow_time_duration = 0.5
		vignette_alpha = 1
	vignette_shader.material.set_shader_parameter("alpha", vignette_alpha)
	Engine.time_scale = time_scale
	await get_tree().create_timer(slow_time_duration * Engine.time_scale).timeout
	Engine.time_scale = 1
