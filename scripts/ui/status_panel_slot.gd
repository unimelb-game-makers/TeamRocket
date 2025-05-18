extends Panel

@onready var info_label: Label = $InfoLabel
@onready var duration_label: Label = $DurationLabel
@onready var stacks_label: Label = $StacksLabel
@onready var texture: TextureRect = $Texture

func set_status(status: StatusEffect, duration: int, stacks: int):
	texture.texture = status.icon
	if (status.duration == StatusEffect.DurationCategory.SECONDS):
		duration_label.text = str(duration) + "s"
	elif (status.duration == StatusEffect.DurationCategory.DAYS):
		duration_label.text = str(duration) + "d"
	if (status.stackable):
		stacks_label.text = str(stacks)
	
	info_label.text = status.name

func _on_mouse_entered() -> void:
	info_label.show()

func _on_mouse_exited() -> void:
	info_label.hide()
