extends Node

var sacrificed = false

func _on_exit_area_body_entered(body: Node2D) -> void:
	switch_to_city()
	
func switch_to_city():
	SaveManager.save_game(Globals.chosen_slot_id)
	var tween = create_tween()
	tween.tween_property($"../GameHandler/CanvasLayer/FadeToBlack", "modulate", Color(0, 0, 0, 2.0), 2.0)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/map/MapGenerator.tscn")

func submit_food(item: Item):
	var buff_i = randi_range(0, 3)
	match buff_i:
		1:
			Globals.player.player_stats.max_health += 5
		2:
			Globals.player.player_stats.speed += 5
		3:
			Globals.player.player_stats.damage += 2
			
	Globals.inventory_ui.update_character_stats()
