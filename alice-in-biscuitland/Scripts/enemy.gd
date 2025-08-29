class_name Enemy
extends Node2D

const whiteRabbit = preload("res://Assets/Sprites/Enemies/White Rabbit.png")
const madHatter = preload("res://Assets/Sprites/Enemies/Mad hatter.png")
const jabberwockyAbove = preload("res://Assets/Sprites/Enemies/Jabberwocky above.png")
const jabberwockyBelow = preload("res://Assets/Sprites/Enemies/Jabberwocky below.png")
const redQueen = preload("res://Assets/Sprites/Enemies/Red Queen.png")

@export var enemyTeacup : Teacup
@export var biscuits : Array[Biscuit]
@onready var below: Sprite2D = $Below
@onready var above: Sprite2D = $Above


var chosenActions : Array[Array] # Dryness Defense Special ToEnemy Name Description
var index : int # Controls what the enemy is
var hovering : bool = false

var defense : int


func set_sprite() -> void:
	match index:
		0:
			# White Rabbit 
			below.texture = whiteRabbit
		1:
			# Mad Hatter
			below.texture = madHatter
		2:
			pass
		3:
			# Jabberwocky
			above.texture = jabberwockyAbove
			below.texture = jabberwockyBelow
		4:
			below.texture = redQueen

func take_dryness(dryness : int) -> void:
	var thirst : int = 0
	if dryness <= defense:
		defense = defense - dryness
	else:
		thirst = dryness - defense
		defense = 0
	enemyTeacup.sip(thirst)

	
func add_defense(_defense : int) -> void:
	defense += _defense
		

func set_action() -> void:
	var actions : Array[Array]
	match index:
		0:
			# White rabbit
			actions.append([10, 0, 0, false, "Whack", "Deals 10 Thirst", "res://Assets/Sprites/Biscuits/Nice.png"])
			actions.append([0, 8, 0, true, "Parry", "Adds 8 Defense", "res://Assets/Sprites/Biscuits/Rich Tea.png"])
		1:
			# Mad hatter
			pass
		2:
			# Cheshire cat
			pass
		3:
			# Jabberwocky
			pass
		4:
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
		
	for i in range(len(actions)):
		var biscuit : Biscuit = biscuits.get(i)
		biscuit.cardName = actions.get(i).get(4)
		biscuit.Description = actions.get(i).get(5)
		biscuit.Img = actions.get(i).get(6)
	
	biscuits.get(0).update_sprites()
	biscuits.get(1).update_sprites()
	biscuits.get(2).update_sprites()
	biscuits.get(0).modulate = Color(1, 1, 1, 1)
	biscuits.get(1).modulate = Color(1, 1, 1, 1)
	biscuits.get(2).modulate = Color(1, 1, 1, 1)
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


func attacking() -> bool:
	for action in chosenActions:
		if action.get(0) != 0 and not action.get(3):
			return true
	return false

func reset() -> void:
	biscuits.get(0).scale = Vector2(1, 1)
	biscuits.get(1).scale = Vector2(1, 1)
	biscuits.get(2).scale = Vector2(1, 1)
	biscuits.get(0).modulate = Color(0, 0, 0, 0)
	biscuits.get(1).modulate = Color(0, 0, 0, 0)
	biscuits.get(2).modulate = Color(0, 0, 0, 0)
	biscuits.get(0).position = Vector2(-1370, 250)
	biscuits.get(1).position = Vector2(-1370, -50)
	biscuits.get(2).position = Vector2(-1370, -350)


func _on_area_2d_mouse_entered() -> void:
	hovering = true


func _on_area_2d_mouse_exited() -> void:
	hovering = false
	
	
func get_health() -> int:
	match index:
		0:
			# White rabbit
			return 25
		1:
			# Mad Hatter
			return 50
		2:
			# Cheshire cat
			return 75
		3:
			# Jabberwocky
			return 80
		4:
			# Her royal majesty
			return 100
	return 0
