extends Node2D

func _process(delta):
	if Input.is_action_just_pressed("slash"):
		var GrassEffect = load("res://Effects/GrassEffect.tscn") #calls the grass effect scene - its inneficient but fast
		var grassEffect = GrassEffect.instance() #makes an instance of the grass effect scene as a node
		var world = get_tree().current_scene #Gets tree of current scene
		world.add_child(grassEffect) #adds instance of the grass effect scene to instance of world node
		grassEffect.global_position = global_position #Sets the grass effects position to the position of the grass
		queue_free() #Removes object from the game at the end of the frame
