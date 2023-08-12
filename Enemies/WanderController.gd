extends Node2D

# Exported variable to set the range within which the entity can wander
export(int) var wander_range = 32

# Variables to hold the starting and target positions for wandering
onready var start_position = global_position
onready var target_position = global_position

# Reference to a timer node to control the duration of wandering
onready var timer = $Timer

# Initialization function
func _ready():
	update_target_position()

# Function to randomly determine a new target position for wandering within the specified range
func update_target_position():
	var target_vector = Vector2(
		rand_range(-wander_range, wander_range),
		rand_range(-wander_range, wander_range)
	)
	target_position = start_position + target_vector

# Function to return the remaining time on the wander timer
func get_time_left():
	return timer.time_left

# Function to start the wander timer with a specified duration
func start_wander_timer(duration):
	timer.start(duration)

# Callback for when the wander timer times out
func _on_Timer_timeout():
	update_target_position()
