extends Node2D

@onready var player: Player = $Player
@onready var interactable_handler: InteractableHandler = $InteractableHandler

func _ready() -> void:
	# Link up signal for each interactable
	for interactable in interactable_handler.interactable_holder.get_children():
		if interactable is CookingActivityStation:
			var station := interactable as CookingActivityStation
			station.is_interacting_with.connect(interacting_with_station)

## Controls what how the handlers and players operate when the player is interacting with a CookingActivityStation 
func interacting_with_station(is_interacting: bool) -> void:
	if is_interacting:
		player.set_player_movement(false) # Disable player movement
	else:
		player.set_player_movement(true) # Enable player movement
	
