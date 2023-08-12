extends KinematicBody2D

# Preloading the sound effect played when the player gets hurt
const PlayerHurtSound = preload("res://Player/PlayerHurtSound.tscn")

# Enumeration for player states
enum { 
	MOVE,
	DODGE,
	SLASH
}

# Reference to player's statistics (like health)
var stats = PlayerStats

# Current state the player character is in (e.g., moving, dodging, slashing)
var state = MOVE

# Variables to control player's movement
var velocity = Vector2.ZERO
var dodge_vector = Vector2.DOWN

# Constants to define player's movement mechanics
const MAX_VELOCITY = 80
const ACCELERATION = 500
const FRICTION = 500
const DODGE_SPEED = 120

# References to various nodes for animation, hitbox functionality, and hurtbox
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var slashHitbox = $HitboxPivot/SwordHitbox
onready var hurtbox = $Hurtbox
onready var blinkAnimationPlayer = $BlinkAnimationPlayer

# Initialization function
func _ready():
	# Set a random seed for any random operations
	randomize()

	# Connect to signals to handle player stats changes and animations
	stats.connect("no_HP", self, "queue_free")

	# Activate the animation tree and set the initial push vector for the hitbox
	animationTree.active = true
	slashHitbox.push_vector = dodge_vector

# Main physics update function
func _physics_process(delta):
	# Handle player's movement and actions based on the current state
	match state:
		MOVE:
			move_state(delta)
		DODGE:
			dodge_state(delta)
		SLASH:
			slash_state(delta)

# Player's logic during MOVE state
func move_state(delta):
	# Calculate the movement input vector based on player's input
	var input_vector = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()

	# Update animations and movement based on the input vector
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

	# Execute the move function to handle actual movement and collisions
	move()

	# Check for specific player inputs to switch to other states
	if Input.is_action_just_pressed("slash"):
		state = SLASH
	if Input.is_action_just_pressed("dodge"):
		state = DODGE

# Player's logic during SLASH state
func slash_state(delta):
	velocity = Vector2.ZERO
	animationState.travel("Slash")

# Player's logic during DODGE state
func dodge_state(delta):
	# Brief invulnerability during dodging
	hurtbox.start_invulnerability(0.5)
	velocity = dodge_vector * DODGE_SPEED
	animationState.travel("Dodge")
	move()

# Handling actual movement and sliding upon collision
func move():
	velocity = move_and_slide(velocity)

# Callback for when SLASH animation finishes
func slash_animation_finished():
	state = MOVE

# Callback for when DODGE animation finishes
func dodge_animation_finished():
	velocity = velocity * 0.5
	state = MOVE

# Callback when the player's hurtbox interacts with something harmful
func _on_Hurtbox_area_entered(area):
	# Reduce player health based on damage received and play hurt animation/sound
	stats.HP -= area.damage
	hurtbox.start_invulnerability(0.6)
	hurtbox.create_hit_effect()
	var playerHurtSound = PlayerHurtSound.instance()
	get_tree().current_scene.add_child(playerHurtSound)
	blinkAnimationPlayer.play("Start")

# Callback for when invulnerability effect ends
func _on_Hurtbox_invulnerability_ended():
	blinkAnimationPlayer.play("Stop")
