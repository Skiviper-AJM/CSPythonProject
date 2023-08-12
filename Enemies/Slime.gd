extends KinematicBody2D

var push = Vector2.ZERO

onready var stats = $Stats

	
func _physics_process(delta): 
	push = push.move_toward(Vector2.ZERO, 200 * delta)
	push = move_and_slide(push)
	
	
func _on_Hurtbox_area_entered(area):
	stats.HP -= 1
	push = area.push_vector * 120


func _on_Stats_no_HP():
	queue_free()
