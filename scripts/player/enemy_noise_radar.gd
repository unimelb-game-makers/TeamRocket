extends Sprite2D

@export var radius: float = 22
@export var radar_item_scene: PackedScene

@onready var update_timer: Timer = $RadarUpdateTimer
@onready var icon_holder = $IconHolder

# var curve_texture: CurveTexture
# var curve: Curve

const LOW_LEVEL = 0.05
const SEPARATE_DISTANCE = 0.2

func _ready() -> void:
	# curve_texture = material.get_shader_parameter("sounds")
	# curve = curve_texture.curve
	await get_tree().process_frame
	await get_tree().process_frame


func update_radar():
	for child in icon_holder.get_children():
		child.queue_free()

	var player_pos = Globals.player.global_position
	for enemy in Globals.enemy_handler.enemy_list:
		var distance = enemy.global_position.distance_to(player_pos)
		if distance <= Globals.player_stats.hearing_sensitivity:
			var pos = direction_to_circle(player_pos.direction_to(enemy.global_position))
			if pos == Vector2.ZERO:
				continue
			var radar_item_inst = radar_item_scene.instantiate()
			icon_holder.add_child(radar_item_inst)
			radar_item_inst.position = pos


# func update_radar_curve():
# 	curve.clear_points()
# 	curve.add_point(Vector2(0, LOW_LEVEL))
# 	curve.add_point(Vector2(1, LOW_LEVEL))
# 	var player_pos = Globals.player.global_position
# 	for enemy in Globals.enemy_handler.enemy_list:
# 		var distance = enemy.global_position.distance_to(player_pos)
# 		if distance <= Globals.player_stats.hearing_sensitivity:
# 			var curve_x_pt = direction_to_range(player_pos.direction_to(enemy.global_position))
# 			if curve_x_pt < 0:
# 				continue
# 			var curve_y_pt = clamp(1.5 - (distance / Globals.player_stats.hearing_sensitivity), 0, 1)
# 			if curve_x_pt - SEPARATE_DISTANCE > 0:
# 				curve.add_point(Vector2(curve_x_pt - SEPARATE_DISTANCE, LOW_LEVEL))
# 			curve.add_point(Vector2(curve_x_pt, curve_y_pt))
# 			if curve_x_pt + SEPARATE_DISTANCE < 1:
# 				curve.add_point(Vector2(curve_x_pt + SEPARATE_DISTANCE, LOW_LEVEL))

func direction_to_circle(dir: Vector2) -> Vector2:
	if dir == Vector2.ZERO:
		return Vector2.ZERO # Handle zero vector case (optional)
	
	var normalized_dir = dir.normalized()
	return normalized_dir * radius

# func direction_to_range(dir: Vector2) -> float:
# 	if dir == Vector2.ZERO:
# 		return -1
# 	var angle = dir.angle()
# 	var normalized_angle = (angle + PI) / (2 * PI) # Map [-PI, PI] to [0,1]
# 	return normalized_angle


func _on_radar_update_timer_timeout() -> void:
	update_radar()
