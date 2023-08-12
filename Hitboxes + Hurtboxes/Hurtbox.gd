extends Area2D

const HitEffect = preload("res://Effects/HitEffect.tscn")

var invulnerable = false setget set_invulnerable

onready var timer = $Timer

signal invulnerability_started
signal invulnerability_ended

func set_invulnerable(value):
	invulnerable = value
	if invulnerable == true:
		emit_signal("invulnerability_started")
	else:
		emit_signal("invulnerability_ended")
	

func start_invulnerability(duration):
	self.invulnerable = true
	timer.start(duration)

func create_hit_effect():
	var effect = HitEffect.instance()
	var main = get_tree().current_scene
	main.add_child(effect)
	effect.global_position = global_position

func _on_Timer_timeout():
	self.invulnerable = false


func _on_Hurtbox_invulnerability_started():
	set_deferred("monitoring", false)


func _on_Hurtbox_invulnerability_ended():
	set_deferred("monitoring", true)
