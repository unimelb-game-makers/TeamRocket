extends Control
class_name PlayerUI

@onready var health_bar: TextureProgressBar = $HealthBar
@onready var gun_texture: TextureRect = $GunInfo/GunTexture
@onready var ammo_count: Label = $GunInfo/AmmoCount
@onready var day_label: Label = $DayLabel
@onready var vignette_shader: ColorRect = $VignetteShader
@onready var minimap: Container = $MinimapBG/Minimap
@onready var minimap_grid: GridContainer = $MinimapBG/Minimap/GridContainer


var vignette_alpha = 0.7
var vignette_fade_speed = 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.player_ui = self
	await get_tree().process_frame
	await get_tree().process_frame
	update_health(Globals.player_stats.health, Globals.player_stats.max_health)
	day_label.text = "Day {0}".format([Globals.current_day])
	vignette_shader.material.set_shader_parameter("alpha", 0)


func _process(delta: float) -> void:
	if vignette_alpha > 0:
		vignette_alpha = vignette_alpha - vignette_fade_speed * delta
		vignette_shader.material.set_shader_parameter("alpha", vignette_alpha)


func update_health(health, max_health):
	health_bar.value = health
	health_bar.max_value = max_health

func update_bullets(bullets, max_bullets):
	ammo_count.text = str(bullets) + "/" + str(max_bullets)

func play_damaged_effect(damaged_amount: int):
	var time_scale = 0.4
	var slow_time_duration = 0.25
	vignette_alpha = 0.8
	# If player lose more than 25% HP, show a stronger effect
	if damaged_amount >= Globals.player_stats.max_health * 0.25:
		time_scale = 0.2
		slow_time_duration = 0.5
		vignette_alpha = 1
	vignette_shader.material.set_shader_parameter("alpha", vignette_alpha)
	Engine.time_scale = time_scale
	await get_tree().create_timer(slow_time_duration * Engine.time_scale).timeout
	Engine.time_scale = 1

func create_minimap(map_grid: Array[Array], current_room: Vector2):
	for child in minimap_grid.get_children():
		child.queue_free()

	for i in range(map_grid.size()):
		for j in range(map_grid[i].size()):
			if map_grid[j][i]:
				if i == current_room.y and j == current_room.x:
					create_minimap_square(Color.GREEN)
				else:
					create_minimap_square(Color.WHITE)
			else:
				create_minimap_square(Color.BLACK)

func create_minimap_square(color: Color):
	var square_inst = ColorRect.new()
	square_inst.modulate = color
	square_inst.custom_minimum_size = Vector2(20, 20)
	minimap_grid.add_child(square_inst)
