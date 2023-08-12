extends KinematicBody2D

var push = Vector2.ZERO

onready var stats = $Stats

const EnemyDeath = preload("res://Effects/EnemyDeath.tscn") #calls the grass effect scene - its inneficient but fast
	
func _physics_process(delta): 
	push = push.move_toward(Vector2.ZERO, 200 * delta)
	push = move_and_slide(push)
	
	
func _on_Hurtbox_area_entered(area):
	stats.HP -= area.damage
	push = area.push_vector * 120

func create_enemy_death():
		var enemyDeath = EnemyDeath.instance() #makes an instance of the grass effect scene as a node
		var world = get_tree().current_scene #Gets tree of current scene
		world.add_child(enemyDeath) #adds instance of the grass effect scene to instance of world node
		enemyDeath.global_position = global_position #Sets the grass effects position to the position of the grass


func _on_Stats_no_HP():
	queue_free()
	create_enemy_death()
