extends Control

@export var recipes: Array[Recipe]
@export var recipe_button_scene: PackedScene

@onready var recipe_grid_container: GridContainer = $BookBackdrop/RecipeListPanel/ScrollContainer/RecipeGridContainer
@onready var recipe_showcase_panel: Panel = $BookBackdrop/RecipeShowcasePanel

var is_open = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	RecipeManager.recipe_ui = self
	recipes = RecipeManager.unlocked_recipes
	load_recipes()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("recipe_book")):
		toggle_book(not visible)

func load_recipes() -> void:
	for child in recipe_grid_container.get_children():
		child.queue_free()
	for recipe in recipes:
		var recipe_button = recipe_button_scene.instantiate()
		recipe_button.recipe = recipe
		recipe_grid_container.add_child(recipe_button)
		recipe_button.update_icon()
		recipe_button.connect("recipe_selected", select_recipe)

func select_recipe(recipe) -> void:
	recipe_showcase_panel.select_recipe(recipe)

func toggle_book(status: bool) -> void:
	visible = status
	is_open = status
