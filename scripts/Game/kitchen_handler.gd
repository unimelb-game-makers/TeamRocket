extends Node

var sacrificed = false

func _on_exit_area_body_entered(body: Node2D) -> void:
	switch_to_city()
	
func switch_to_city():
	call_deferred("change_scene_to_file", "res://scenes/environments/City.tscn")

func submit_food(item: Item):
	var buff_i = randi_range(0,3)
	match buff_i:
		1:
			Globals.player_hp_increase += 0.2
		2:
			Globals.player_speed_increase += 0.2
		3:
			Globals.player_damage_increase += 0.2
			
	Globals.inventory_ui.update_character_stats()
