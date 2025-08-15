extends Area2D

@onready var death_timer: Timer = $Timer
@onready var light: PointLight2D = $PointLight2D

@export var is_permanent: bool = false

const FADE_SPEED = 3

var start_disappear = false

func _ready() -> void:
	death_timer.start()

func _process(delta: float) -> void:
	if start_disappear:
		modulate.a -= delta * FADE_SPEED
		light.energy -= delta * FADE_SPEED
		if modulate.a <= 0 and light.energy <= 0:
			queue_free()


func _on_timer_timeout() -> void:
	if is_permanent:
		return
	start_disappear = true
