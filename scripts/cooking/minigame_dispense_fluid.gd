extends Node2D


var goal_blobs = 400

func _process(delta: float) -> void:
	pass

func _on_timer_timeout() -> void:
	if $FluidGenerator.bodies.size() >= goal_blobs:
		$FluidGenerator.set_process(false)
		$Next.visible = true


func _on_fluid_generator_created_blob() -> void:
	if $FluidGenerator.bodies.size() > goal_blobs:
		$Timer.start()
