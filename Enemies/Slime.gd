extends KinematicBody2D

# Preloaded visual effect scene for the slime's death
const EnemyDeath = preload("res://Effects/EnemyDeath.tscn")

# Exposed variables for customizing the slime's movement characteristics from the editor
export var ACCELERATION = 300
export var MAX_VELOCITY = 50
export var FRICTION = 200
export var WANDER_FREQUENCY = 4

# Enumeration for the slime's possible states
enum {
	STATIC,  # Slime is stationary
	WANDER,  # Slime is wandering randomly
	PERSUIT  # Slime is chasing the player
}

# Variables for state and movement
var state = PERSUIT
var velocity = Vector2.ZERO

# Push vector used when the slime is hit or pushed by an external force
var push = Vector2.ZERO

# References to various child nodes for different functionalities
onready var stats = $Stats
onready var playerDetection = $PlayerDetectionZone
onready var sprite = $AnimatedSprite
onready var hurtbox = $Hurtbox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var animationPlayer = $AnimationPlayer

# Initialization function
func _ready():
	state = pick_random_state([STATIC, WANDER])

# Main physics update function
func _physics_process(delta): 
	# Gradually reduce the push vector over time
	push = push.move_toward(Vector2.ZERO, 200 * delta)
	push = move_and_slide(push)
	
	# Behavior logic based on the slime's current state
	match state:
		STATIC:
			# Slowly come to a stop and look for the player
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			find_player()
			if wanderController.get_time_left() == 0:
				update_wander()
		WANDER:
			# Check for the player and wander around if not found
			find_player()
			if wanderController.get_time_left() == 0:
				update_wander()
			accelerate_towards_point(wanderController.target_position, delta)
			if global_position.distance_to(wanderController.target_position) <= 2:
				state = STATIC
		PERSUIT:
			# Chase the player if detected, else revert to STATIC state
			var player = playerDetection.player
			if player:
				accelerate_towards_point(player.global_position, delta)
			else:
				state = STATIC

	# Handle soft collisions with environment
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
	velocity = move_and_slide(velocity)

# Function to accelerate the slime towards a target point
func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_VELOCITY, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0

# Function to randomly decide between the STATIC and WANDER states for the slime
func update_wander():
	state = pick_random_state([STATIC, WANDER])
	wanderController.start_wander_timer(rand_range(1, 3))

# Function to check if the player is within detection range
func find_player():
	if playerDetection.can_see_player():
		state = PERSUIT

# Function to pick a random state from a given list
func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

# Callback for when the slime is hit by something (e.g., player attack)
func _on_Hurtbox_area_entered(area):
	stats.HP -= area.damage
	push = area.push_vector * 120
	hurtbox.create_hit_effect()
	hurtbox.start_invulnerability(0.3)

# Function to instantiate and display the death effect when the slime dies
func create_enemy_death():
	var enemyDeath = EnemyDeath.instance()
	var world = get_tree().current_scene
	world.add_child(enemyDeath)
	enemyDeath.global_position = global_position

# Callback for when the slime's health reaches zero
func _on_Stats_no_HP():
	queue_free()
	create_enemy_death()

# Callbacks for visual feedback during the slime's invulnerability period
func _on_Hurtbox_invulnerability_started():
	animationPlayer.play("Start")
func _on_Hurtbox_invulnerability_ended():
	animationPlayer.play("Stop")
