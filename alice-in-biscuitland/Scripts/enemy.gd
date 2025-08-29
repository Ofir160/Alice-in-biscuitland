class_name Enemy
extends Node2D

const whiteRabbit = preload("res://Assets/Sprites/Enemies/White Rabbit.png")
const madHatter = preload("res://Assets/Sprites/Enemies/Mad hatter.png")
const jabberwockyAbove = preload("res://Assets/Sprites/Enemies/Jabberwocky above.png")
const jabberwockyBelow = preload("res://Assets/Sprites/Enemies/Jabberwocky below.png")
const cheshireCat = preload("res://Assets/Sprites/Enemies/Cheshire Cat.png")
const redQueen = preload("res://Assets/Sprites/Enemies/Red Queen.png")

@export var enemyTeacup : Teacup
@export var biscuits : Array[Biscuit]
@export var eatAnimation : AnimationPlayer
@export var eatAnimationBiscuit : Sprite2D
@export var descriptionAnimation : AnimationPlayer
@export var description : RichTextLabel
@onready var below: Sprite2D = $Below
@onready var above: Sprite2D = $Above

var chosenActions : Array[Array] # Dryness Defense Special ToEnemy Name Description
var index : int # Controls what the enemy is
var hovering : bool = false

var defense : int
var attackPower : int
var defensePower : int

enum WhiteRabbit {WHACK = 0, PARRY = 1, BOON = 2, BUFF = 3, IM_LATE = 4}
enum MadHatter {BATTER = 0, REBUFF = 1, EMPOWER = 2, BONANZA = 3, BATTER_R = 4, REBUFF_R = 5, EMPOWER_R = 6, BONANZA_R = 7, SPIKE = 8, INTOXICATE = 9 }
enum CheshireCat {SCRATCH = 0, PAW = 1, BITE = 2, MAIM = 3, CURSE = 4, VANISH = 5}
enum Jabberwocky {SWIPE = 0, SLASH = 1, BARRICADE = 2, SCORCH = 3, ENFLAME = 4, JAWS_AND_CLAWS = 5}
enum RedQueen {BOLSTER = 0, ARROGANCE = 1, ROYAL_STRIKE = 2, SNARKY = 3, SUMMON_GUARDS = 4, SIEZE_HER = 5, ENRAGE = 6, ROYAL_TOILET_PAPER = 7, OFF_WITH_YOUR_HEAD = 8}

var whiteRabbitActions = [
	[3, 0, 0, true, "Whack", "Deals 3 Thirst.", "res://Assets/Sprites/Biscuits/Nice.png", WhiteRabbit.WHACK],
	[0, 3, 0, true, "Parry", "Adds 3 Defense.", "res://Assets/Sprites/Biscuits/Nice.png", WhiteRabbit.PARRY],
	[0, 0, 2, true, "Boon", "Gain 1 Thirst Power.", "res://Assets/Sprites/Biscuits/Nice.png", WhiteRabbit.BOON], 
	[0, 0, 3, true, "Buff", "Gain 1 Defense Power.", "res://Assets/Sprites/Biscuits/Nice.png", WhiteRabbit.BUFF],
	[0, 0, 1, true, "I'm Late!", "Gain 1 Thirst Power every turn.", "res://Assets/Sprites/Biscuits/Nice.png", WhiteRabbit.IM_LATE]
]
var madHatterActions = [
	[5, 0, 0, false, "Batter", "Deals 5 Thirst.", "res://Assets/Sprites/Biscuits/Nice.png", MadHatter.BATTER],
	[0, 5, 0, false, "Rebuff", "Adds 5 Defense.", "res://Assets/Sprites/Biscuits/Nice.png", MadHatter.REBUFF],
	[0, 0, 2, false, "Empower", "Gain 1 Thirst Power.", "res://Assets/Sprites/Biscuits/Nice.png", MadHatter.EMPOWER],
	[0, 0, 3, false, "Bonanza", "Gain 1 Defense Power.", "res://Assets/Sprites/Biscuits/Nice.png", MadHatter.BONANZA],
	[0, 0, 4, false, "Batter?", "Deals a random amount of Thirst. Between 3 to 10.", "res://Assets/Sprites/Biscuits/Nice.png", MadHatter.BATTER_R],
	[0, 0, 5, false, "Rebuff?", "Adds a random amount of Defense. Between 3 to 10.", "res://Assets/Sprites/Biscuits/Nice.png", MadHatter.REBUFF_R],
	[0, 0, 6, false, "Empower?", "Gain a random amount of Thirst Power. Between 0 to 3", "res://Assets/Sprites/Biscuits/Nice.png", MadHatter.EMPOWER_R],
	[0, 0, 7, false, "Bonanza?", "Gain a random amount of Defense Power. Between 0 to 3", "res://Assets/Sprites/Biscuits/Nice.png", MadHatter.BONANZA_R],
	[0, 0, 8, false, "Spike", "Spikes your tea. You must play a random amount of biscuits on your next turn.", "res://Assets/Sprites/Biscuits/Nice.png", MadHatter.SPIKE],
	[0, 0, 1, false, "Intoxicate", "Becomes intoxicated. Everything is random!", "res://Assets/Sprites/Biscuits/Nice.png", MadHatter.INTOXICATE],
]

var cheshireCatActions = [
	[5, 0, 0, false, "Scratch", "Deals 5 Thirst.", "res://Assets/Sprites/Biscuits/Nice.png", CheshireCat.SCRATCH],
	[0, 5, 0, false, "Paw", "Adds 5 Defense.", "res://Assets/Sprites/Biscuits/Nice.png", CheshireCat.PAW],
	[10, 0, 0, false, "Bite", "Deals 10 Thirst.", "res://Assets/Sprites/Biscuits/Nice.png", CheshireCat.BITE],
	[0, 0, 9, false, "Maim", "Lose 1 Thirst Power. Lose 1 Defense Power.", "res://Assets/Sprites/Biscuits/Nice.png", CheshireCat.MAIM],
	[0, 0, 10, false, "Curse", "Adds a useless biscuit to your discard pile.", "res://Assets/Sprites/Biscuits/Nice.png", CheshireCat.CURSE],
	[0, 0, 1, false, "Vanish", "Becomes invisible.", "res://Assets/Sprites/Biscuits/Nice.png", CheshireCat.VANISH],
]

var jabberwockyActions = [
	[5, 0, 0, false, "Swipe", "Deals 5 Thirst.", "res://Assets/Sprites/Biscuits/Nice.png", Jabberwocky.SWIPE],
	[12, 0, 0, false, "Slash", "Deals 12 Thirst.", "res://Assets/Sprites/Biscuits/Nice.png", Jabberwocky.SLASH],
	[0, 12, 0, false, "Barricade", "Adds 12 Defense.", "res://Assets/Sprites/Biscuits/Nice.png", Jabberwocky.BARRICADE],
	[0, 0, 11, false, "Scorch", "Set's your tea ablaze. The next biscuit you dunk in it will sink.", "res://Assets/Sprites/Biscuits/Nice.png", Jabberwocky.SCORCH],
	[0, 0, 1, false, "Enflame", "Becomes enraged. Gains 1 Thirst Power every time you apply Thirst to this enemy", "res://Assets/Sprites/Biscuits/Nice.png", Jabberwocky.ENFLAME],
	[20, 0, 0, false, "Jaws and Claws", "Deals 20 Thirst.", "res://Assets/Sprites/Biscuits/Nice.png", Jabberwocky.JAWS_AND_CLAWS],
]

var redQueenActions = [
		[0, 15, 0, false, "Bolster", "Add 15 Defense.", "res://Assets/Sprites/Biscuits/Nice.png", RedQueen.BOLSTER],
		[0, 0, 12, false, "Arrogance", "Gain 3 Thirst Power.", "res://Assets/Sprites/Biscuits/Nice.png", RedQueen.ARROGANCE],
		[15, 0, 0, false, "Royal Strike", "Deals 15 Thirst.", "res://Assets/Sprites/Biscuits/Nice.png", RedQueen.ROYAL_STRIKE],
		[0, 0, 13, false, "Snarky", "You lose 1 Defense Power.", "res://Assets/Sprites/Biscuits/Nice.png", RedQueen.SNARKY],
		[0, 0, 16, false, "Summon Guards", "Summons the guards.", "res://Assets/Sprites/Biscuits/Nice.png", RedQueen.SUMMON_GUARDS],
		[0, 0, 17, false, "SIEZE HER!", "Deals 3 Thirst for every guard.", "res://Assets/Sprites/Biscuits/Nice.png", RedQueen.SIEZE_HER],
		[0, 0, 14, false, "Enrage", "Becomes angry. Gair 5 Thirst Power. Do not mess with her.", "res://Assets/Sprites/Biscuits/Nice.png", RedQueen.ENRAGE],
		[0, 0, 15, false, "Royal Toilet Paper", "Heals 10 Tea.", "res://Assets/Sprites/Biscuits/Nice.png", RedQueen.ROYAL_TOILET_PAPER],
		[25, 0, 0, false, "OFF WITH YOUR HEAD!", "Deal 25 Thirst.", "res://Assets/Sprites/Biscuits/Nice.png", RedQueen.OFF_WITH_YOUR_HEAD],
]

var stateSpace : Dictionary[int, Array]
# The key is the move. 
# The array contains the number of times the move is used consecutively and how many times its been used

var specialState : bool
var actionCount : int
var redQueenGuardCount : int

func set_sprite() -> void:
	match index:
		0:
			# White Rabbit 
			below.texture = whiteRabbit
		1:
			# Mad Hatter
			below.texture = madHatter
		2:
			above.texture = cheshireCat
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

func update_state_space(actions : Array[Array]) -> void:
	for i in len(actions):
		var action = actions.get(i)
		var key : int = action.get(7)
		var data : Array = [stateSpace.get(key).get(0) + 1, stateSpace.get(key).get(1) + 1]
		stateSpace.set(key, data)
		for currentKey in stateSpace.keys():
			if key != currentKey:
				var newData : Array = [0, stateSpace.get(currentKey).get(1)]
				stateSpace.set(currentKey, newData)

func initialize_state_space() -> void:
	match index:
		0:
			for i in len(WhiteRabbit.keys()):
				stateSpace.set(i, [0, 0])
		1:
			for i in len(MadHatter.keys()):
				stateSpace.set(i, [0, 0])
		2:
			for i in len(CheshireCat.keys()):
				stateSpace.set(i, [0, 0])
		3:
			for i in len(Jabberwocky.keys()):
				stateSpace.set(i, [0, 0])
		4:
			for i in len(RedQueen.keys()):
				stateSpace.set(i, [0, 0])

func white_rabbit(lastAction : int, value : float) -> Array[Array]:
	var actions : Array[Array]
	if actionCount == 0:
		actions.append(whiteRabbitActions[WhiteRabbit.WHACK])
	elif actionCount == 1:
		actions.append(whiteRabbitActions[WhiteRabbit.WHACK])
	elif actionCount == 2:
		actions.append(whiteRabbitActions[WhiteRabbit.BOON])
	elif actionCount == 3:
		actions.append(whiteRabbitActions[WhiteRabbit.WHACK])
	elif actionCount == 4:
		actions.append(whiteRabbitActions[WhiteRabbit.IM_LATE])
	else:
		match lastAction:
			WhiteRabbit.WHACK:
				if stateSpace.get(WhiteRabbit.WHACK).get(0) >= 3:
					actions.append(whiteRabbitActions[WhiteRabbit.PARRY])
				else:
					if value <= 0.5:
						actions.append(whiteRabbitActions[WhiteRabbit.PARRY])
					else:
						actions.append(whiteRabbitActions[WhiteRabbit.WHACK])
			WhiteRabbit.PARRY:
				if stateSpace.get(WhiteRabbit.BUFF).get(1) >= 1:
					actions.append(whiteRabbitActions[WhiteRabbit.WHACK])
				else:
					if value <= 0.5:
						actions.append(whiteRabbitActions[WhiteRabbit.WHACK])
					else:
						actions.append(whiteRabbitActions[WhiteRabbit.BUFF])
			WhiteRabbit.BOON:
				actions.append(whiteRabbitActions[WhiteRabbit.WHACK])
			WhiteRabbit.BUFF:
				actions.append(whiteRabbitActions[WhiteRabbit.PARRY])
			WhiteRabbit.IM_LATE:
				actions.append(whiteRabbitActions[WhiteRabbit.WHACK])
	return actions

func mad_hatter(lastAction : int, value : float) -> Array[Array]:
	var actions : Array[Array]
	
	if actionCount == 0:
		actions.append(madHatterActions[MadHatter.BATTER])
	elif actionCount == 1:
		actions.append(madHatterActions[MadHatter.EMPOWER])
		actions.append(madHatterActions[MadHatter.BONANZA])
	elif actionCount == 2:
		actions.append(madHatterActions[MadHatter.REBUFF])
	elif actionCount == 3:
		actions.append(madHatterActions[MadHatter.SPIKE])
		actions.append(madHatterActions[MadHatter.BATTER])
	elif actionCount == 4:
		actions.append(madHatterActions[MadHatter.INTOXICATE])
	elif actionCount == 5:
		actions.append(madHatterActions[MadHatter.BATTER_R])
	else:
		match lastAction:
			MadHatter.BATTER_R:
				if stateSpace.get(MadHatter.BATTER_R).get(0) >= 2:
					if value <= 0.4:
						actions.append(madHatterActions[MadHatter.REBUFF_R])
					elif value <= 0.8:
						actions.append(madHatterActions[MadHatter.EMPOWER_R])
						actions.append(madHatterActions[MadHatter.BONANZA_R])
					else:
						actions.append(madHatterActions[MadHatter.SPIKE])
						actions.append(madHatterActions[MadHatter.BATTER_R])
				else:
					if value <= 0.3:
						actions.append(madHatterActions[MadHatter.BATTER_R])
					elif value <= 0.6:
						actions.append(madHatterActions[MadHatter.REBUFF_R])
					elif value <= 0.9:
						actions.append(madHatterActions[MadHatter.EMPOWER_R])
						actions.append(madHatterActions[MadHatter.BONANZA_R])
					else:
						actions.append(madHatterActions[MadHatter.SPIKE])
						actions.append(madHatterActions[MadHatter.BATTER_R])
			MadHatter.EMPOWER_R:
				if value <= 0.2:
					actions.append(madHatterActions[MadHatter.SPIKE])
					actions.append(madHatterActions[MadHatter.BATTER_R])
				elif value <= 0.6:
					actions.append(madHatterActions[MadHatter.BATTER_R])
				else:
					actions.append(madHatterActions[MadHatter.REBUFF_R])
			MadHatter.BONANZA_R:
				if value <= 0.2:
					actions.append(madHatterActions[MadHatter.SPIKE])
					actions.append(madHatterActions[MadHatter.BATTER_R])
				elif value <= 0.6:
					actions.append(madHatterActions[MadHatter.BATTER_R])
				else:
					actions.append(madHatterActions[MadHatter.REBUFF_R])
			MadHatter.REBUFF_R:
				if value <= 0.5:
					actions.append(madHatterActions[MadHatter.BATTER_R])
				else:
					actions.append(madHatterActions[MadHatter.BONANZA_R])
					actions.append(madHatterActions[MadHatter.EMPOWER_R])
			MadHatter.SPIKE:
				actions.append(madHatterActions[MadHatter.BATTER_R])
	return actions

func cheshire_cat(lastAction : int, value : float) -> Array[Array]:
	var actions : Array[Array]
	return actions
	
func jabberwocky(lastAction : int, value : float) -> Array[Array]:
	var actions : Array[Array]
	return actions
	
func red_queen(lastAction : int, value : float) -> Array[Array]:
	var actions : Array[Array]
	return actions

func choose_actions(index : int) -> Array[Array]:
	var actions : Array[Array]
	
	var lastAction : int
	for action in stateSpace.keys():
		if stateSpace.get(action).get(0) != 0:
			lastAction = action
	var value = randf()
	match index:
		0:
			actions = white_rabbit(lastAction, value)
		1:
			actions = mad_hatter(lastAction, value)
		2:
			actions = cheshire_cat(lastAction, value)
		3:
			actions = jabberwocky(lastAction, value)
		4:
			actions = red_queen(lastAction, value)
	actionCount += 1
	update_state_space(actions)
	return actions

func set_action() -> void:
	var actions : Array[Array]
	match index:
		0:
			# White rabbit

			actions = choose_actions(0)
		1:
			# Mad Hatter
			
			actions = choose_actions(1)
		2:
			# Cheshire cat
			
			# Small thirst and defense. 5 for both
			# actions.append([5, 0, 0, false, "Spike", "Spikes you. Randomizes how many cards you need to play", "res://Assets/Sprites/Biscuits/Nice.png"])
			# actions.append([0, 5, 0, false, "Spike", "Spikes you. Randomizes how many cards you need to play", "res://Assets/Sprites/Biscuits/Nice.png"])
			# Basic thirst. 10
			# actions.append([10, 0, 0, false, "Spike", "Spikes you. Randomizes how many cards you need to play", "res://Assets/Sprites/Biscuits/Nice.png"])
			
			# Special card. Decrease player's thirst power and defense power by one
			# actions.append([0, 0, 9, false, "Spike", "Spikes you. Randomizes how many cards you need to play", "res://Assets/Sprites/Biscuits/Nice.png"])
			# Special card. Give's player a curse card
			# actions.append([0, 0, 10, false, "Curse", "Gives you a curse card", "res://Assets/Sprites/Biscuits/Lotus Biscoff.png"])
			
			# Invisible state. Makes next attack redundant
			# actions.append([0, 0, 1, true, "Invisible", "Next attack card played does nothing", "res://Assets/Sprites/Biscuits/Nice.png"])
			
			actions = choose_actions(2)
		3:
			# Jabberwocky
			
			# Weak attack. 5
			# actions.append([5, 0, 0, false, "Jaws and Claws", "Deals 5 Thirst", "res://Assets/Sprites/Biscuits/Nice.png"])
			
			# Basic attack. 12
			# actions.append([12, 0, 0, false, "Slash", "Deals 12 Thirst", "res://Assets/Sprites/Biscuits/Nice.png"])
			# Basic defense. 12
			# actions.append([0, 12, 0, false, "Spike", "Spikes you. Randomizes how many cards you need to play", "res://Assets/Sprites/Biscuits/Nice.png"])
			
			# Special card. Increases dunk chance to 100 for next biscuit
			# actions.append([0, 0, 11, false, "Burn", "The next card dunked in tea will sink", "res://Assets/Sprites/Biscuits/Nice.png"])
			# Fire state. Every time you attack him his thirst power increase
			# actions.append([0, 0, 1, false, "Fire", "Every time you apply Thirst, Gains 1 Thirst Power", "res://Assets/Sprites/Biscuits/Nice.png"])
			# Big attack. 20
			# actions.append([20, 0, 0, false, "Jaws and Claws", "Deals 20 Thirst", "res://Assets/Sprites/Biscuits/Nice.png"])
			
			actions = choose_actions(3)
		4:
			# The Red Queen
			
			# Basic defense. 15
			# actions.append([0, 15, 0, false, "Fire", "Every time you apply Thirst, Gains 1 Thirst Power", "res://Assets/Sprites/Biscuits/Nice.png"])
			# Thirst power up. 3
			# actions.append([0, 0, 12, false, "Fire", "Gains 3 Thirst Power", "res://Assets/Sprites/Biscuits/Nice.png"])
			# Basic attack. 15
			# actions.append([15, 0, 0, false, "Fire", "Deals 15 Thirst", "res://Assets/Sprites/Biscuits/Nice.png"])
			# Decrease player defense power up. 1
			# actions.append([0, 0, 13, false, "Fire", "Every time you apply Thirst, Gains 1 Thirst Power", "res://Assets/Sprites/Biscuits/Nice.png"])
			
			# Big attack. 25. OFF WITH YOUR HEAD
			# actions.append([25, 0, 0, false, "OFF WITH YOUR HEAD", "Deals 25 Thirst", "res://Assets/Sprites/Biscuits/Nice.png"])
			# Anger state. Increase thirst power up. 5
			# actions.append([0, 0, 14, false, "Anger", "Becomes Angry", "res://Assets/Sprites/Biscuits/Nice.png"])
			
			# Special card. Heal for 10.
			# actions.append([0, 0, 15, false, "Heal", "Heals for 10 Tea", "res://Assets/Sprites/Biscuits/Nice.png"])
			# Special card. summon biscuit soldiers
			# actions.append([0, 0, 16, false, "Summon", "Summons the Guards", "res://Assets/Sprites/Biscuits/Nice.png"])
			# Attack card. Soldiers attack. 3 per soldier. Increases based on thirst power
			# actions.append([0, 0, 17, false, "SIEZE HER", "Deals 3 Thirst per Guard Summoned", "res://Assets/Sprites/Biscuits/Nice.png"])
			
			actions = choose_actions(4)
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
	if specialState:
		match index:
			0:
				description.text = "Gains 1 Thirst Power every Turn"
			1:
				description.text = "Enemy biscuits become random!"
			2:
				description.text = "The next Thirst biscuit played will not apply Thirst"
			3:
				description.text = "Gains 1 Thirst Power every time you apply Thirst to this enemy"
			4:
				description.text = "Very Angry"
		
		descriptionAnimation.play("appear")
	hovering = true

func _on_area_2d_mouse_exited() -> void:
	if specialState:
		descriptionAnimation.play("vanish")
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

func eat_biscuit_player(index : int, onPlayer : bool) -> void:
	eatAnimationBiscuit.texture = load(chosenActions.get(index).get(6))
	
	if onPlayer:
		eatAnimation.play("Player")
	else:
		eatAnimation.play("Enemy")

func init() -> void:
	set_sprite()
	initialize_state_space()
