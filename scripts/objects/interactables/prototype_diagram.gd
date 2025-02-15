extends Sprite2D

func interact():
	$UI.visible = not $UI.visible

func _on_area_2d_body_exited(body: Node2D) -> void:
	$UI.hide()
