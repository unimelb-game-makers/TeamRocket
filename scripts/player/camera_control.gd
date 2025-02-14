extends Camera2D



func _ready():
	connect("aim_mode_enter", Callable(self, "enter_aim_mode"))
	connect("aim_mode_exit", Callable(self, "exit_aim_mode"))

func _process(delta: float) -> void:
	
	pass

func enter_aim_mode():
	pass

func exit_aim_mode():
	pass
