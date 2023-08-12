extends KinematicBody2D

# Visual effect for slime's termination for the slime's death
const SlimeDemiseEffect = preload("res://Effects/EnemyDeath.tscn")

# Editor customization variables for movement the slime's movement characteristics from the editor
export var MOTION_BOOST = 300
export var TOP_SLIME_SPEED = 50
export var DRAG = 200
export var ROAM_INTERVAL = 4

# Enumeration for the slime's possible activity_modes
enum {
	STATIC,  # Slime is stationary
	WANDER,  # Slime is wandering randomly
	PERSUIT  # Slime is chasing the player
}

# Variables for activity_mode and movement
var activity_mode = PERSUIT
var movement_rate = Vector2.ZERO

# Vector for external forces on slime the slime is hit or pushed by an external force
var push = Vector2.ZERO

# Node references for diverse functionalities for different functionalities
onready var slimeAttributes = $Stats
onready var playerLocator = $PlayerDetectionZone
onready var slimeImage = $AnimatedSprite
onready var damageDetector = $Hurtbox
onready var softImpact = $SoftCollision
onready var roamManager = $WanderController
onready var slimeAnimation = $AnimationPlayer

# Set initial parameters for the slime
func _ready():
	activity_mode = pick_random_activity_mode([STATIC, WANDER])

# Main update loop related to physics
func _physics_process(delta): 
	# Gradually reduce the push vector over time
	push = push.move_toward(Vector2.ZERO, 200 * delta)
	push = move_and_slide(push)
	
	# Behavior logic based on the slime's current activity_mode
	match activity_mode:
		STATIC:
			# Slowly come to a stop and look for the player
			movement_rate = movement_rate.move_toward(Vector2.ZERO, DRAG * delta)
			find_player()
			if roamManager.get_time_left() == 0:
				update_wander()
		WANDER:
			# Check for the player and wander around if not found
			find_player()
			if roamManager.get_time_left() == 0:
				update_wander()
			accelerate_towards_point(roamManager.target_position, delta)
			if global_position.distance_to(roamManager.target_position) <= 2:
				activity_mode = STATIC
		PERSUIT:
			# Chase the player if detected, else revert to STATIC activity_mode
			var player = playerLocator.player
			if player:
				accelerate_towards_point(player.global_position, delta)
			else:
				activity_mode = STATIC

	# Handle soft collisions with environment
	if softImpact.is_colliding():
		movement_rate += softImpact.get_push_vector() * delta * 400
	movement_rate = move_and_slide(movement_rate)

# Move slime towards a target point towards a target point
func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	movement_rate = movement_rate.move_toward(direction * TOP_SLIME_SPEED, MOTION_BOOST * delta)
	slimeImage.flip_h = movement_rate.x < 0

# Choose randomly between STATIC and WANDER between the STATIC and WANDER activity_modes for the slime
func update_wander():
	activity_mode = pick_random_activity_mode([STATIC, WANDER])
	roamManager.start_wander_timer(rand_range(1, 3))

# Determine if player is in detection range is within detection range
func find_player():
	if playerLocator.can_see_player():
		activity_mode = PERSUIT

# Function to pick a random activity_mode from a given list
func pick_random_activity_mode(activity_mode_list):
	activity_mode_list.shuffle()
	return activity_mode_list.pop_front()

# When slime receives damage by something (e.g., player attack)
func _on_Hurtbox_area_entered(area):
	slimeAttributes.HP -= area.damage
	push = area.push_vector * 120
	damageDetector.create_hit_effect()
	damageDetector.start_invulnerability(0.3)

# Display visual effect upon slime's death the death effect when the slime dies
func create_enemy_death():
	var enemyDeath = SlimeDemiseEffect.instance()
	var world = get_tree().current_scene
	world.add_child(enemyDeath)
	enemyDeath.global_position = global_position

# Handle events when slime's health depletes reaches zero
func _on_Stats_no_HP():
	queue_free()
	create_enemy_death()

# Visual cues during slime's invulnerability phase during the slime's invulnerability period
func _on_Hurtbox_invulnerability_started():
	slimeAnimation.play("Start")
func _on_Hurtbox_invulnerability_ended():
	slimeAnimation.play("Stop")
