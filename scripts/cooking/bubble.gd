extends Node2D
class_name Bubble


func _on_button_pressed() -> void:
	$Bubble.visible = false
	$Pop.visible = true
	$Button.queue_free() # In case a bubble appears in the same place
	$Timer.start()

func _on_timer_timeout() -> void:
	queue_free()
