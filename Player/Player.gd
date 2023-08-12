extends KinematicBody2D


# Variables:
const MAX_SPEED = 80
const ACCELERATION = 500
const FRICTION = 500

var velocity = Vector2.ZERO


# Called at runtime.
#func _ready():
#	print("Hello World")

#Runs every frame/ tick physics is active. Delta ensures it runs at the same speed even on a laggy machine
func _physics_process(delta):
	#Gets inputs based on input strength (binary on keyboard, but variable on a gamepad)
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized() #Normalises the vector, basically stops diagonal movement being excessively fast
	
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta) #Makes player accelerate to their max speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta) #Makes player decelerate via friction
	
	print(velocity)
	velocity = move_and_slide(velocity) #Handles collission natively - in such a way you slide accross colided objects (also pre-bakes delta into the function)
	