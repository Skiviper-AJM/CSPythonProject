extends KinematicBody2D

# Loading the sound when player is hurt played when the player gets hurt
const PlayerDamageSound = preload("res://Player/PlayerHurtSound.tscn")

# Possible states for the player character
enum { 
	MOVE,
	DODGE,
	SLASH
}

# Player's health and other stats reference (like health)
var playerStats = PlayerStats

# Current state the player character is in (e.g., moving, dodging, slashing)
var state = MOVE

# Variables to control player's perform_movement
var perform_movementVelocity = Vector2.ZERO
var evadeDirection = Vector2.DOWN

# Constants to define player's perform_movement mechanics
const TOP_SPEED = 80
const SPEED_INCREASE = 500
const SPEED_DECREASE = 500
const EVADE_RATE = 120

# Nodes linked to animations, hitboxes, and other functionalities, hitbox functionality, and damageZone
onready var animPlayer = $AnimationPlayer
onready var animTree = $AnimationTree
onready var stateAnim = animTree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitbox
onready var damageZone = $Hurtbox
onready var flickerAnimPlayer = $BlinkAnimationPlayer

# Function to initialize player parameters
func _ready():
	# Set a random seed for any random operations
	randomize()

	# Connect to signals to handle player playerStats changes and animations
	playerStats.connect("no_HP", self, "queue_free")

	# Activate the animation tree and set the initial push vector for the hitbox
	animTree.active = true
	swordHitbox.push_vector = evadeDirection

# Main function for physics-related updates
func _physics_process(delta):
	# Handle player's perform_movement and actions based on the current state
	match state:
		MOVE:
			handle_perform_move(delta)
		DODGE:
			handle_evade(delta)
		SLASH:
			handle_slash(delta)

# Logic executed when player is in MOVE mode
func handle_perform_move(delta):
	# Calculate the perform_movement input vector based on player's input
	var directionInput = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()

	# Update animations and perform_movement based on the input vector
	if directionInput != Vector2.ZERO:
		evadeDirection = directionInput
		swordHitbox.push_vector = directionInput
		animTree.set("parameters/Idle/blend_position", directionInput)
		animTree.set("parameters/Run/blend_position", directionInput)
		animTree.set("parameters/Slash/blend_position", directionInput)
		animTree.set("parameters/Dodge/blend_position", directionInput)
		stateAnim.travel("Run")
		perform_movementVelocity = perform_movementVelocity.move_toward(directionInput * TOP_SPEED, SPEED_INCREASE * delta)
	else:
		stateAnim.travel("Idle")
		perform_movementVelocity = perform_movementVelocity.move_toward(Vector2.ZERO, SPEED_DECREASE * delta)

	# Execute the perform_move function to handle actual perform_movement and collisions
	perform_move()

	# Check for specific player inputs to switch to other states
	if Input.is_action_just_pressed("slash"):
		state = SLASH
	if Input.is_action_just_pressed("dodge"):
		state = DODGE

# Logic executed when player is in SLASH mode
func handle_slash(delta):
	perform_movementVelocity = Vector2.ZERO
	stateAnim.travel("Slash")

# Logic executed when player is in DODGE mode
func handle_evade(delta):
	# Brief invulnerability during dodging
	damageZone.start_invulnerability(0.5)
	perform_movementVelocity = evadeDirection * EVADE_RATE
	stateAnim.travel("Dodge")
	perform_move()

# Handling actual perform_movement and sliding upon collision
func perform_move():
	perform_movementVelocity = move_and_slide(perform_movementVelocity)

# Function called post SLASH animation
func slash_animation_finished():
	state = MOVE

# Function called post DODGE animation
func dodge_animation_finished():
	perform_movementVelocity = perform_movementVelocity * 0.5
	state = MOVE

# Callback when the player's damageZone interacts with something harmful
func _on_Hurtbox_area_entered(area):
	# Reduce player health based on damage received and play hurt animation/sound
	playerStats.HP -= area.damage
	damageZone.start_invulnerability(0.6)
	damageZone.create_hit_effect()
	var playerHurtSound = PlayerDamageSound.instance()
	get_tree().current_scene.add_child(playerHurtSound)
	flickerAnimPlayer.play("Start")

# Callback for when invulnerability effect ends
func _on_Hurtbox_invulnerability_ended():
	flickerAnimPlayer.play("Stop")
