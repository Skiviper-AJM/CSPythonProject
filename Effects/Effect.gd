extends AnimatedSprite

# Initialization function
func _ready(): 
	# Connect to the 'animation_finished' signal to handle behavior after the animation plays out
	connect("animation_finished", self, "_on_animation_finished")
	
	# Initialize the frame to 0
	frame = 0
	
	# Start the "Animate" animation
	play("Animate")

# Callback function to handle the behavior after the animation finishes
func _on_animation_finished():
	# Remove the effect object from the scene once the animation is done
	queue_free()
