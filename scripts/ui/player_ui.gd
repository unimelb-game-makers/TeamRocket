extends Control
class_name PlayerUI

@onready var health_bar: TextureProgressBar = $HealthBar
@onready var gun_texture: TextureRect = $GunInfo/GunTexture
@onready var ammo_count: Label = $GunInfo/AmmoCount
@onready var timer: Label = $TimerProgressBar/Timer
@onready var timer_progress_bar: TextureProgressBar = $TimerProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.player_ui = self
	update_health(Globals.player_stats.health, Globals.player_stats.max_health)

func update_health(health, max_health):
	health_bar.value = health
	health_bar.max_value = max_health

func update_bullets(bullets, max_bullets):
	ammo_count.text = str(bullets) + "/" + str(max_bullets)

func update_time(time):
	timer.text = "%02d:%02d" % [time / 60, time % 60]
	timer_progress_bar.value = 1440 - time
