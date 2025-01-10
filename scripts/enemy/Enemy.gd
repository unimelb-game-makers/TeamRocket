class_name Enemy
extends Node

@export var max_health: int
@export var base_move_speed: float
@export var base_damage: int
@export var base_attack_cooldown: float

@export var detection_radius: int
@export var chase_radius: int

var health = max_health
var move_speed = base_move_speed
