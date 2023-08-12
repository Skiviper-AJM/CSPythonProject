extends Node2D

func _process(delta):
	if Input.is_action_just_pressed("attack"):
		queue_free() #Removes object from the game at the end of the frame
