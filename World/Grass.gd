extends Node2D

const GrassEffect = preload("res://Effects/GrassEffect.tscn") #calls the grass effect scene - its inneficient but fast


func create_grass_effect():
		var grassEffect = GrassEffect.instance() #makes an instance of the grass effect scene as a node
		var world = get_tree().current_scene #Gets tree of current scene
		world.add_child(grassEffect) #adds instance of the grass effect scene to instance of world node
		grassEffect.global_position = global_position #Sets the grass effects position to the position of the grass

func _on_Hurtbox_area_entered(area): #checks the hurtbox collision
	create_grass_effect()
	queue_free() #deletes item at end of frame
