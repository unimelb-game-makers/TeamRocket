extends Basic_Enemy


var dash_attack_vector: Vector2 # Position of player when winding up
var dash_attack_speed: float = 1500

var dash_attack_timer: float = 0
var dash_attack_duration: float = 1

var current_dashes = 0
var num_dashes = 3

func _on_wind_up_state_entered() -> void:
	velocity = Vector2.ZERO
	dash_attack_vector = Vector2(target_creature.position)


func _on_wind_up_state_physics_processing(delta: float) -> void:
	move_and_slide()

func _on_dash_attack_state_entered() -> void:
	current_dashes += 1
	

func _on_dash_attack_state_physics_processing(delta: float) -> void:
	dash_attack_timer += delta
	if dash_attack_timer >= dash_attack_duration:
		$StateChart.send_event("on_dash_attack_finish")
	else:
		velocity = dash_attack_vector * roll_speed(dash_attack_timer)
		move_and_slide()

func _on_dash_attack_state_exited() -> void:
	# Exit entire Attack state, go back to Active state
	if current_dashes == num_dashes:
		statechart.send_event("on_attack_finish")


func roll_speed(elapsed_time : float) -> float:
	var roll_start_speed_multiplier = 1.5
	var roll_end_speed_multiplier = 0.5
	var t = elapsed_time / dash_attack_duration
	var curve = 1 - t * t  # Quick start and smooth slowdown
	var start_speed = dash_attack_speed * roll_start_speed_multiplier
	var end_speed = PASSIVE_SPEED * roll_end_speed_multiplier
	return start_speed - (start_speed - end_speed) * curve
