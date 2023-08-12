extends KinematicBody2D


# Variables:
const MAX_SPEED = 100
const ACCELERATION = 10
const FRICTION = 10

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
		velocity += input_vector * ACCELERATION * delta #Makes player accelerate
		velocity = velocity.clamped(MAX_SPEED * delta) #Sets the max speed by preventing velocity passing it
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta) #Makes player decelerate via friction
	
	print(velocity)
	move_and_collide(velocity)
	
