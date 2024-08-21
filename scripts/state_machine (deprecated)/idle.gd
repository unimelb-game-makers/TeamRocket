extends playerState

var movements = [  ]

func enter() -> void:
	super()
	parent.velocity = Vector2.ZERO

func exit() -> void:
	pass


func process_input(event: InputEvent) -> playerState:
	
	
	return null

func process_frame(delta: float) -> playerState:
	return null

func process_physics(delta: float) -> playerState:
	return null
