@tool
class_name MinigameSettings
extends Resource

@export var difficulty: int = 1: ## The higher the number, the more difficult
	set(new_dif):
		if new_dif < 1:
			return
		difficulty = new_dif
