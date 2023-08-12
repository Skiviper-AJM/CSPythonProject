extends Node

export(int) var max_HP = 4 setget set_max_HP
var HP = max_HP setget set_HP

signal no_HP
signal HP_changed(value)
signal max_HP_changed(value)

func set_max_HP(value):
	max_HP = value
	self.HP = min(HP, max_HP)
	emit_signal("max_HP_changed", max_HP)

func set_HP(value):
	HP = value
	emit_signal("HP_changed", HP)
	if HP <= 0: 
		emit_signal("no_HP")

func _ready():
	self.HP = max_HP
