class_name Player
extends Node2D

var thirst : int
var defense : int

func take_dryness(dryness : int) -> void:
	if dryness <= defense:
		defense = defense - dryness
	else:
		thirst += dryness - defense
		defense = 0


func add_defense(_defense : int) -> void:
	defense += _defense
