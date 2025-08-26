class_name Enemy
extends Node2D

var chosenActions : Array[Array] # Dryness Defense Special
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
	var actions : Array[Array]
	actions.append([0, 0, 0])
	actions.append([0, 0, 0])
	actions.append([0,0,0])
	match index:
		0:
			# White rabbit
			actions.set(0, [10, 0, 0])
			actions.set(1, [10, 0, 0])
			actions.set(2, [0, 0, 0])
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
	if len(actions) == 3:
		pass
		#$AnimationPlayer1.play("Fly 1")
		#$AnimationPlayer2.play("Fly 2")
		#$AnimationPlayer3.play("Fly 3")
	elif len(actions) == 2:
		pass
		#$AnimationPlayer1.play("Fly 1")
		#$AnimationPlayer2.play("Fly 2")
	elif len(actions) == 1:
		pass
		#$AnimationPlayer1.play("Fly 1")
		
	$"Enemy Attack 1".update_sprites()
	$"Enemy Attack 2".update_sprites()
	$"Enemy Attack 3".update_sprites()
	chosenActions = actions


func get_actions() -> Array[Array]:
	if len(chosenActions) == 3:
		pass
		#$AnimationPlayer1.play("Play Biscuits Player1")
		#$AnimationPlayer2.play("Play Biscuits Player2")
		#$AnimationPlayer3.play("Play Biscuits Player3")
	elif len(chosenActions) == 2:
		pass
		#$AnimationPlayer1.play("Play Biscuits Player1")
		#$AnimationPlayer2.play("Play Biscuits Player2")
	elif len(chosenActions) == 1:
		pass
		#$AnimationPlayer1.play("Play Biscuits Player1")
	return chosenActions


func _on_area_2d_mouse_entered() -> void:
	hovering = true


func _on_area_2d_mouse_exited() -> void:
	hovering = false
