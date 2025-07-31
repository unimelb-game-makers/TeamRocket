extends StaticBody2D


func _on_entry_body_entered(_body: Node2D) -> void:
    Globals.game_handler.switch_to_kitchen()
