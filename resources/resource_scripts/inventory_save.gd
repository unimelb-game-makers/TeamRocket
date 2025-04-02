class_name InventorySave
extends Resource

@export var player_inventory: Dictionary
@export var fridge_inventory: Dictionary

func reset_inventories():
	clear_player_inventory()
	
func clear_player_inventory():
	player_inventory = {}

func clear_fridge_inventory():
	fridge_inventory = {}
