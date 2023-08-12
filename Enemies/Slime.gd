extends KinematicBody2D

# Vector representing a push force (e.g., from being hit)
var push = Vector2.ZERO

# References to child nodes and their functionalities
onready var stats = $Stats             # Node reference to keep track of enemy stats (like health)
onready var playerDetection = $PlayerDetectionZone  # Node reference to detect player's presence
onready var sprite = $AnimatedSprite   # Node reference to control sprite animations

# Load a scene for visual effects upon enemy death
const EnemyDeath = preload("res://Effects/EnemyDeath.tscn")

# Exposed variables to modify enemy movement characteristics from the editor
export var ACCELERATION = 300
export var MAX_VELOCITY = 50
export var FRICTION = 200

# Enumeration for enemy states
enum {
	STATIC,    # Enemy is not moving
	WANDER,    # Enemy is roaming around
	PERSUIT    # Enemy is chasing the player
}

# Variables for movement and state
var velocity = Vector2.ZERO
var state = PERSUIT

# Main physics update function
func _physics_process(delta): 
	# Reduce the push vector over time
	push = push.move_toward(Vector2.ZERO, 200 * delta)
	push = move_and_slide(push)

	# State machine to determine enemy behavior
	match state:
		STATIC:
			# Decelerate to a halt and check for player
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			find_player()
		WANDER:
			# Placeholder for future logic
			pass
		PERSUIT:
			# Chase the player if detected
			var player = playerDetection.player
			if player != null:
				var direction = (player.global_position - global_position).normalized()
				velocity = velocity.move_toward(direction * MAX_VELOCITY, ACCELERATION * delta)
			else: 
				# Switch to STATIC state if player is lost
				state = STATIC
	
	# Flip sprite based on movement direction
	sprite.flip_h = velocity.x < 0
	velocity = move_and_slide(velocity)
			
# Function to check for player presence and switch state if detected
func find_player():
	if playerDetection.can_see_player():
		state = PERSUIT

# Callback when the enemy is hit by something (like a player attack)
func _on_Hurtbox_area_entered(area):
	# Reduce enemy health based on damage received and apply a push effect
	stats.HP -= area.damage
	push = area.push_vector * 120

# Function to create a visual effect upon enemy death
func create_enemy_death():
	var enemyDeath = EnemyDeath.instance()  # Create an instance of the death effect scene
	var world = get_tree().current_scene    # Reference the current scene (world)
	world.add_child(enemyDeath)             # Add the effect to the world
	enemyDeath.global_position = global_position  # Set the effect's position to the enemy's position

# Callback when the enemy's health drops to zero
func _on_Stats_no_HP():
	queue_free()  # Remove the enemy from the scene
	create_enemy_death()  # Display the death effect
