extends Node2D
class_name PlaceablePOI

enum EnterDirectionEnum {
    NONE,
    TOP,
    DOWN,
    LEFT,
    RIGHT
}

@export var potential_enter_direction: EnterDirectionEnum

@onready var enemy_holder: Node2D = $EnemyHolder
@onready var interactable_holder: Node2D = $InteractableHolder