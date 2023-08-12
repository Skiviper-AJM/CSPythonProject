extends Area2D

# Preloading the visual effect for when an entity gets hit
const HitEffect = preload("res://Effects/HitEffect.tscn")

# Variable to determine if the entity is currently invulnerable to damage
var invulnerable = false setget set_invulnerable

# Reference to a timer node to handle invulnerability duration
onready var timer = $Timer

# Signals to broadcast the start and end of invulnerability
signal invulnerability_started
signal invulnerability_ended

# Setter function for the invulnerable property
func set_invulnerable(value):
	invulnerable = value
	if invulnerable:
		emit_signal("invulnerability_started")
	else:
		emit_signal("invulnerability_ended")

# Function to start an invulnerability period with a specified duration
func start_invulnerability(duration):
	self.invulnerable = true
	timer.start(duration)

# Function to create a visual effect when an entity is hit
func create_hit_effect():
	var effect = HitEffect.instance()
	var main = get_tree().current_scene
	main.add_child(effect)
	effect.global_position = global_position

# Callback for when the invulnerability timer runs out
func _on_Timer_timeout():
	self.invulnerable = false

# Callback for when invulnerability starts - disables monitoring to avoid further damage
func _on_Hurtbox_invulnerability_started():
	set_deferred("monitoring", false)

# Callback for when invulnerability ends - re-enables monitoring for damage
func _on_Hurtbox_invulnerability_ended():
	set_deferred("monitoring", true)
