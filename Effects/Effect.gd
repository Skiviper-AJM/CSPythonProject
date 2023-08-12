extends AnimatedSprite

#Script for catch-all animated sprite handling

func _ready(): 
	connect("animation_finished", self, "_on_animation_finished") #self references in code to determine when the parents animation ends
	frame = 0 #sets frame to 0 on startup
	play("Animate") #tells parent to animate


func _on_animation_finished(): #triggers when the connected animation ends
	queue_free()#removes object at the end of the frame

