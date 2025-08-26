class_name Enemy
extends Node2D

var chosenAction : Array # Dryness Defense Special
var index : int # Controls what the enemy is
var hovering : bool = false

var thirst : int
var defense : int
var teaLevel : int


func take_dryness(dryness : int) -> void:
	if dryness <= defense:
		defense = defense - dryness
	else:
		thirst += dryness - defense
		defense = 0
		

func sip(amount : int) -> bool:
	teaLevel -= amount
	print(teaLevel)
	if teaLevel <= 0:
		return true
	return false
		 
func add_defense(_defense : int) -> void:
	defense += _defense
		

func set_action() -> void:
	var action : Array
	for i in range(3):
		action.append(0)
	match index:
		0:
			# White rabbit
			action.set(0, 5)
			action.set(1, 10)
		1:
			# Cook
			pass
		2:
			# Mad hatter
			pass
		3:
			# Cheshire cat
			pass
		4:
			# Jabberwocky
			pass
		5:
			# The Red Queen
			pass
	chosenAction = action


func get_action() -> Array:
	return chosenAction
