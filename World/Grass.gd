extends Node2D

# Preload the grass effect for visual feedback when the grass is interacted with
const GrassEffect = preload("res://Effects/GrassEffect.tscn")

# Function to create a visual effect upon grass interaction
func create_grass_effect():
	# Instantiate the grass effect scene
	var grassEffect = GrassEffect.instance()
	# Get the current scene (world)
	var world = get_tree().current_scene
	# Add the effect instance to the world
	world.add_child(grassEffect)
	# Set the effect's position to the grass's position
	grassEffect.global_position = global_position

# Callback for when something interacts with the grass (e.g., player steps on it)
func _on_Hurtbox_area_entered(area):
	create_grass_effect()
	# Remove the grass from the scene after interaction
	queue_free()
