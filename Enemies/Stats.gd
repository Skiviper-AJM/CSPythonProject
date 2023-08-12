extends Node

export(int) var max_HP = 1
onready var HP = max_HP setget set_HP

signal no_HP

func set_HP(value):
	HP = value
	if HP <= 0: 
		emit_signal("no_HP")
