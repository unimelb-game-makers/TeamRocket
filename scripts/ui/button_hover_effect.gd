extends BaseButton
class_name TemplateButton

var scale_factor = 1.1

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _process(_delta: float) -> void:
	pivot_offset = size / 2

func _on_mouse_entered():
	if disabled:
		return
	var tween = self.create_tween()
	tween.tween_property(self, "scale", Vector2(scale_factor, scale_factor), 0.2)

func _on_mouse_exited():
	pivot_offset = size / 2
	var tween = self.create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 0.2)
