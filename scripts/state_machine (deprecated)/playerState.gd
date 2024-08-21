class_name playerState
extends Node

@export
var animation_name : String
@export
var move_speed : float = 300


# Used dependency injection here rather than hardcoding them
var parent: CharacterBody2D
var animations: AnimatableBody2D
var move_component

func enter() -> void:
	#parent.animations.play(animation_name)
	#animations.play(animation_name)
	pass

func exit() -> void:
	pass

func process_input(event: InputEvent) -> playerState:
	return null

func process_frame(delta: float) -> playerState:
	return null

func process_physics(delta: float) -> playerState:
	return null

func get_gravity() -> float:
	return move_component.jump_gravity if parent.velocity.y < 0 else move_component.fall_gravity

# Roll
func get_movement_input() -> float:
	return move_component.get_movement_direction()
