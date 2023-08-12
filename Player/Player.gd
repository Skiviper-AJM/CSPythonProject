extends KinematicBody2D


# Variables:
var velocity = Vector2.ZERO


# Called at runtime.
#func _ready():
#	print("Hello World")

#Runs every frame/ tick physics is active. 
func _physics_process(delta):
	#Gets inputs based on input strength (binary on keyboard, but variable on a gamepad)
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	if input_vector != Vector2.ZERO:
		velocity = input_vector
	else:
		velocity = Vector2.ZERO
	
	move_and_collide(velocity)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
