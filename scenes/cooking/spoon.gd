extends RigidBody2D

var is_dragging = false
var offset : Vector2 = Vector2.ZERO
signal clicked

func _ready() -> void:
	set_freeze_mode(FREEZE_MODE_STATIC)

func _physics_process(delta: float) -> void:
	if is_dragging:
		position = get_global_mouse_position() - offset

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			clicked.emit(self)
			offset = get_global_mouse_position() - global_position

func pickup():
	if is_dragging:
		return
	set_freeze_enabled(true)
	is_dragging = true

func drop(impulse=Vector2.ZERO):
	if is_dragging:
		set_freeze_enabled(false)
		apply_central_impulse(impulse)
		is_dragging = false
