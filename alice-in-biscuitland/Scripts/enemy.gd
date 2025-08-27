class_name Enemy
extends Node2D

var chosenActions : Array[Array] # Dryness Defense Special ToEnemy
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
	if teaLevel <= 0:
		return true
	return false
		 
		
func add_defense(_defense : int) -> void:
	defense += _defense
		

func set_action() -> void:
	var actions : Array[Array]
	match index:
		0:
			# White rabbit
			actions.append([10, 0, 0, true])
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
		$AnimationPlayer1.play("Fly 1")
		$AnimationPlayer2.play("Fly 2")
		$AnimationPlayer3.play("Fly 3")
	elif len(actions) == 2:
		$AnimationPlayer1.play("Fly 1")
		$AnimationPlayer2.play("Fly 2")
	elif len(actions) == 1:
		$AnimationPlayer1.play("Fly 1")
		
	$"Enemy Attack 1".update_sprites()
	$"Enemy Attack 2".update_sprites()
	$"Enemy Attack 3".update_sprites()
	$"Enemy Attack 1".modulate = Color(1, 1, 1, 1)
	$"Enemy Attack 2".modulate = Color(1, 1, 1, 1)
	$"Enemy Attack 3".modulate = Color(1, 1, 1, 1)
	chosenActions = actions


func get_actions() -> Array[Array]:
	if len(chosenActions) == 3:
		var biscuit1Animation = "Play Biscuits Enemy1" if chosenActions.get(0).get(3) else "Play Biscuits Player1"
		$AnimationPlayer1.play(biscuit1Animation)
		var biscuit2Animation = "Play Biscuits Enemy2" if chosenActions.get(1).get(3) else "Play Biscuits Player2"
		$AnimationPlayer2.play(biscuit2Animation)
		var biscuit3Animation = "Play Biscuits Enemy3" if chosenActions.get(2).get(3) else "Play Biscuits Player3"
		$AnimationPlayer3.play(biscuit3Animation)
	elif len(chosenActions) == 2:
		var biscuit1Animation = "Play Biscuits Enemy1" if chosenActions.get(0).get(3) else "Play Biscuits Player1"
		$AnimationPlayer1.play(biscuit1Animation)
		var biscuit2Animation = "Play Biscuits Enemy2" if chosenActions.get(1).get(3) else "Play Biscuits Player2"
		$AnimationPlayer2.play(biscuit2Animation)
	elif len(chosenActions) == 1:
		var biscuit1Animation = "Play Biscuits Enemy1" if chosenActions.get(0).get(3) else "Play Biscuits Player1"
		$AnimationPlayer1.play(biscuit1Animation)
	return chosenActions


func reset() -> void:
	$"Enemy Attack 1".scale = Vector2(1, 1)
	$"Enemy Attack 2".scale = Vector2(1, 1)
	$"Enemy Attack 3".scale = Vector2(1, 1)
	$"Enemy Attack 1".modulate = Color(0, 0, 0, 0)
	$"Enemy Attack 2".modulate = Color(0, 0, 0, 0)
	$"Enemy Attack 3".modulate = Color(0, 0, 0, 0)
	$"Enemy Attack 1".position = Vector2(-1370, 200)
	$"Enemy Attack 2".position = Vector2(-1370, -100)
	$"Enemy Attack 3".position = Vector2(-1370, -400)


func _on_area_2d_mouse_entered() -> void:
	hovering = true


func _on_area_2d_mouse_exited() -> void:
	hovering = false
