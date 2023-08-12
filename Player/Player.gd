extends KinematicBody2D

# Enumeration for character states
enum { 
	MOVE,
	DODGE,
	SLASH
}

var stats = PlayerStats

# State to track the current action the character is performing
var state = MOVE

# Vector to represent character movement
var velocity = Vector2.ZERO

# Vector to dictate the direction of the dodge move
var dodge_vector = Vector2.DOWN

# Constants for controlling movement mechanics
const MAX_VELOCITY = 80
const ACCELERATION = 500
const FRICTION = 500
const DODGE_SPEED = 120

# Variables for animation and hitbox functionalities
onready var animationPlayer = $AnimationPlayer # Node reference to play animations
onready var animationTree = $AnimationTree # Node reference to control animation logic
onready var animationState = animationTree.get("parameters/playback") # Node reference for playback control in the animation tree
onready var slashHitbox = $HitboxPivot/SwordHitbox # Node reference for the hitbox during a slash action
onready var hurtbox = $Hurtbox

func _ready():
	stats.connect("no_HP", self, "queue_free")
	# Initialize the animation tree and set push vector for hitbox
	animationTree.active = true
	slashHitbox.push_vector = dodge_vector

# Main physics update function
func _physics_process(delta):
	# State machine handling the character's current action
	match state:
		MOVE: 
			move_state(delta)
		DODGE:
			dodge_state(delta)
		SLASH:
			slash_state(delta)
	
# Logic for when the character is in MOVE state
func move_state(delta):
	# Get movement input from the player
	var input_vector = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()

	# Check for movement and update animations and mechanics accordingly
	if input_vector != Vector2.ZERO:
		dodge_vector = input_vector
		slashHitbox.push_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Slash/blend_position", input_vector)
		animationTree.set("parameters/Dodge/blend_position", input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_VELOCITY, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	# Handle character movement and collision
	move()

	# Check for action inputs to switch states
	if Input.is_action_just_pressed("slash"):
		state = SLASH
	if Input.is_action_just_pressed("dodge"):
		#PlayerStats.max_HP -= 1 #test stat change for making sure max hp alteration works as intended
		state = DODGE
	
# Logic for when the character is in SLASH state
func slash_state(delta):
	velocity = Vector2.ZERO
	animationState.travel("Slash")
	
# Logic for when the character is in DODGE state
func dodge_state(delta):
	velocity = dodge_vector * DODGE_SPEED
	animationState.travel("Dodge")
	move()

# Function to handle movement and sliding upon collision
func move():
	velocity = move_and_slide(velocity)
	
# Callback for when the slash animation finishes
func slash_animation_finished():
	state = MOVE
	
# Callback for when the dodge animation finishes
func dodge_animation_finished():
	velocity = velocity * 0.5
	state = MOVE


func _on_Hurtbox_area_entered(area):
	stats.HP -= 1
	hurtbox.start_invulnerability(0.5)
	hurtbox.create_hit_effect()
