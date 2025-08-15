extends Panel

@export var summons: Dictionary[String, PackedScene]

func _on_deer_button_pressed() -> void:
	spawn_enemy("deer")

func _on_chicken_button_pressed() -> void:
	spawn_enemy("chicken")

func _on_spider_button_pressed() -> void:
	spawn_enemy("spider")

func _on_bird_button_pressed() -> void:
	spawn_enemy("raven")

func _on_stalker_button_pressed() -> void:
	spawn_enemy("stalker")

func _on_monarch_button_pressed() -> void:
	spawn_enemy("rat_monarch")

func spawn_enemy(enemy_name):
	var spawn_position = Globals.player.global_position + Globals.player.direction * 20.0
	var enemy_spawn: Enemy = summons[enemy_name].instantiate()
	Globals.enemy_handler.add_child(enemy_spawn)
	Globals.enemy_handler.add_enemy_to_list(enemy_spawn)
	enemy_spawn.position = spawn_position
