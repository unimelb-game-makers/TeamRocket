extends Enemy

enum STATE {NEUTRAL, CHASING}

func _ready() -> void:
	super()
	state = STATE.NEUTRAL
