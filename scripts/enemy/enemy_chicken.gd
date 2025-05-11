extends BasicEnemy

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionRadius
@onready var hurt_effect: AudioStreamPlayer2D = $SoundEffects/HurtEffect
@onready var idle_effect: AudioStreamPlayer2D = $SoundEffects/IdleEffect
@onready var run_effect: AudioStreamPlayer2D = $SoundEffects/RunEffect
@onready var stop_run_timer: Timer = $StopRunTimer

var direction = Vector2(0, 0)
var runaway_duration = 5.0


func _on_runaway_state_physics_processing(_delta: float) -> void:
	if target_creature != null:
		direction = target_creature.global_position.direction_to(global_position)
	velocity = direction * movement_speed
	if (velocity.x > 0.0):
		animated_sprite_2d.flip_h = true
	else:
		animated_sprite_2d.flip_h = false
	move_and_slide()

func _on_runaway_state_entered() -> void:
	animated_sprite_2d.play("walk", 3.0)
	stop_run_timer.start(runaway_duration)


func _on_detection_radius_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		target_creature = area.get_parent();
		direction = target_creature.global_position.direction_to(global_position)
		stop_run_timer.start(runaway_duration)
		statechart.send_event("to_runaway")


func _on_detection_radius_area_exited(_area: Area2D) -> void:
	return

# Override BasicEnemy behaviour
func _on_chase_radius_area_entered(_area: Area2D) -> void:
	return

# Override BasicEnemy behaviour
func _on_chase_radius_area_exited(_area: Area2D) -> void:
	return

func damage(value) -> void:
	super (value)
	play_sound("hurt")
	if target_creature != null:
		direction = target_creature.global_position.direction_to(global_position)
	else:
		direction = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	stop_run_timer.start(runaway_duration)
	statechart.send_event("to_runaway")


func alerted(sound_position: Vector2):
	direction = sound_position.direction_to(global_position)
	stop_run_timer.start(runaway_duration)
	statechart.send_event("to_runaway")


func _on_stop_run_timer_timeout() -> void:
	# If player still nearby, continue run
	if detection_area.has_overlapping_bodies():
		stop_run_timer.start(runaway_duration)
	else:
		statechart.send_event("to_return")
		animated_sprite_2d.play("walk")
