extends Area2D

# Variable to hold a reference to the player when detected in the detection zone
var player = null

# Function to check if the detection zone can currently "see" the player
func can_see_player():
	return player != null

# Callback for when a body (e.g., player) enters the detection zone
func _on_PlayerDetectionZone_body_entered(body):
	player = body

# Callback for when a body (e.g., player) exits the detection zone
func _on_PlayerDetectionZone_body_exited(body):
	player = null
