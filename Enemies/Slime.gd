extends KinematicBody2D

var push = Vector2.ZERO

onready var stats = $Stats
onready var playerDetection = $PlayerDetectionZone
onready var sprite = $AnimatedSprite

const EnemyDeath = preload("res://Effects/EnemyDeath.tscn") #calls the grass effect scene - its inneficient but fast
export var ACCELERATION = 300
export var MAX_VELOCITY = 50
export var FRICTION = 200

enum {
	STATIC,
	WANDER,
	PERSUIT
}

var velocity = Vector2.ZERO
var state = PERSUIT

func _physics_process(delta): 
	push = push.move_toward(Vector2.ZERO, 200 * delta)
	push = move_and_slide(push)
	
	match state:
		STATIC:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			find_player()
		WANDER:
			pass
		PERSUIT:
			var player = playerDetection.player
			if player != null:
				var direction = (player.global_position - global_position).normalized()
				velocity = velocity.move_toward(direction * MAX_VELOCITY, ACCELERATION * delta)
			else: 
				state = STATIC
	sprite.flip_h = velocity.x < 0
	velocity = move_and_slide(velocity)
			
			
func find_player():
	if playerDetection.can_see_player():
		state = PERSUIT
	
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
