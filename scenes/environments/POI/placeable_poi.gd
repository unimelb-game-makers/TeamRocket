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
@onready var spawn_holder: Node2D = $SpawnHolder
@onready var interactable_holder: Node2D = $InteractableHolder


func get_enemy_spawns():
    return spawn_holder.get_children()

func get_enemies():
    return enemy_holder.get_children()

func get_interactables():
    return interactable_holder.get_children()