extends Panel
@onready var max_hp_text_edit: LineEdit = $VBoxContainer/MaxHP/MaxHPLineEdit
@onready var hp_text_edit: LineEdit = $VBoxContainer/HP/HPLineEdit
@onready var damage_text_edit: LineEdit = $VBoxContainer/Damage/DamageLineEdit
@onready var speed_text_edit: LineEdit = $VBoxContainer/Speed/SpeedLineEdit
@onready var max_stamina_text_edit: LineEdit = $VBoxContainer/MaxStamina/MaxStaminaLineEdit
@onready var stamina_regen_text_edit: LineEdit = $VBoxContainer/StaminaRegen/StaminaRegenLineEdit

func _ready() -> void:
	max_hp_text_edit.text = str(Globals.player_stats.max_health)
	hp_text_edit.text = str(Globals.player_stats.health)
	damage_text_edit.text = str(Globals.player_stats.damage)
	speed_text_edit.text = str(Globals.player_stats.speed)
	max_stamina_text_edit.text = str(Globals.player_stats.max_stamina)
	stamina_regen_text_edit.text = str(Globals.player_stats.stamina_regen)

func _on_max_hp_text_edit_text_set(value) -> void:
	if (max_hp_text_edit.text.is_valid_int()):
		Globals.player_stats.max_health = int(max_hp_text_edit.text)

func _on_hp_text_edit_text_set(value) -> void:
	if (hp_text_edit.text.is_valid_int()):
		Globals.player_stats.health = int(hp_text_edit.text)

func _on_damage_text_edit_text_set(value) -> void:
	if (damage_text_edit.text.is_valid_int()):
		Globals.player_stats.damage = int(damage_text_edit.text)

func _on_speed_text_edit_text_set(value) -> void:
	if (speed_text_edit.text.is_valid_int()):
		Globals.player_stats.speed = int(speed_text_edit.text)

func _on_max_stamina_text_edit_text_set(value) -> void:
	if (max_stamina_text_edit.text.is_valid_int()):
		Globals.player_stats.max_stamina = int(max_stamina_text_edit.text)

func _on_stamina_regen_text_edit_text_set(value) -> void:
	if (stamina_regen_text_edit.text.is_valid_int()):
		Globals.player_stats.stamina_regen = int(stamina_regen_text_edit.text)
