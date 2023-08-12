extends KinematicBody2D


# Variables:

#for my 3 main movement calculations - caps speed, determines rate of acceleration and the rate you slow down on release
const MAX_SPEED = 80
const ACCELERATION = 500
const FRICTION = 500

enum { 
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var velocity = Vector2.ZERO

# Called at runtime.
onready var animationPlayer = $AnimationPlayer #calls animation player child at runtime
onready var animationTree = $AnimationTree #Calls animation tree - which internally handles animation logic via a simple tree / blendspace
onready var animationState = animationTree.get("parameters/playback")

func _ready():
	animationTree.active = true #enables the animation trees when the game starts


#Runs every frame/ tick physics is active. Delta ensures it runs at the same speed even on a laggy machine
func _physics_process(delta):
	match state: #essentially godots version of a switch statement
		MOVE: 
			move_state(delta)
		
		ROLL:
			roll_state(delta)
		
		ATTACK:
			attack_state(delta)
	
func move_state(delta):
	#Gets inputs based on input strength (binary on keyboard, but variable on a gamepad)
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized() #Normalises the vector, basically stops diagonal movement being excessively fast
	
	if input_vector != Vector2.ZERO: #detects movement by checking if input is NOT 0, input being if you touched the related keys
		animationTree.set("parameters/Idle/blend_position", input_vector) #sets either run or idle to active from the animation tree
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run") #Sets run to active animation when "Travelling"
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta) #Makes player accelerate to their max speed
	else:
		animationState.travel("Idle") #Sets state to idle when not moving / no input
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta) #Makes player decelerate via friction
	
	
	velocity = move_and_slide(velocity) #Handles collission natively - in such a way you slide accross colided objects (also pre-bakes delta into the function)
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
	if Input.is_action_just_pressed("roll"):
		state = ROLL
	
func attack_state(delta):
	velocity = Vector2.ZERO
	animationState.travel("Attack")
	
func attack_animation_finished():
	state = MOVE
	
func roll_state(delta):
	velocity = velocity * 2
	animationState.travel("Roll")
	
func roll_animation_finished():
	state = MOVE
