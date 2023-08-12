extends AudioStreamPlayer

# Initialization function
func _ready():
	# Connect the 'finished' signal of the audio player to remove it once the sound finishes playing
	connect("finished", self, "queue_free")
