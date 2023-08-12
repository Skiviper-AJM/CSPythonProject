extends Node

# Exposed variable for setting the maximum health points from the editor
export(int) var max_HP = 4 setget set_max_HP

# Variable to represent the current health points
var HP = max_HP setget set_HP

# Signals to broadcast when HP changes, max HP changes, or the entity runs out of HP
signal no_HP
signal HP_changed(value)
signal max_HP_changed(value)

# Initialization function
func _ready():
	self.HP = max_HP

# Setter function for max_HP property, clamping current HP if it exceeds the new max
func set_max_HP(value):
	max_HP = value
	self.HP = min(HP, max_HP)
	emit_signal("max_HP_changed", max_HP)

# Setter function for HP property, emitting relevant signals based on HP changes
func set_HP(value):
	HP = value
	emit_signal("HP_changed", HP)
	if HP <= 0: 
		emit_signal("no_HP")
