class_name Enemy
extends Node2D

const hover = preload("res://Assets/Audio/SFX/biscuitHover.ogg")
const unhover = preload("res://Assets/Audio/SFX/biscuitUnhover.ogg")

const pop1 = preload("res://Assets/Audio/SFX/pop 1.mp3")
const pop2 = preload("res://Assets/Audio/SFX/pop 2.mp3")
const pop3 = preload("res://Assets/Audio/SFX/pop 3.mp3")

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
@export var dialogueAnimation : AnimationPlayer
@export var dialogue : RichTextLabel
@export var dialogueBox : CollisionShape2D
@export var helperText : RichTextLabel
@export var dialogueTimer : Timer
@export var typewriterTimer : Timer
@export var typerwriterSound : AudioStreamPlayer2D
@export var deckManager : DeckManager

@onready var below: Sprite2D = $Below
@onready var above: Sprite2D = $Above

@export var sfx : AudioStreamPlayer2D

var chosenActions : Array[Array] # Dryness Defense Special ToEnemy Name Description
var index : int # Controls what the enemy is
var hovering : bool = false
var hoveringDialogue : bool = false
var dialogueCounter : int = 0
var dialogueTypewriterFinished : bool

var defense : int
var attackPower : int
var defensePower : int

enum WhiteRabbit {WHACK = 0, PARRY = 1, BOON = 2, BUFF = 3, IM_LATE = 4}
enum MadHatter {BATTER = 0, REBUFF = 1, EMPOWER = 2, BONANZA = 3, BATTER_R = 4, REBUFF_R = 5, EMPOWER_R = 6, BONANZA_R = 7, SPIKE = 8, INTOXICATE = 9 }
enum CheshireCat {SCRATCH = 0, PAW = 1, BITE = 2, MAIM = 3, CURSE = 4, VANISH = 5}
enum Jabberwocky {SWIPE = 0, SLASH = 1, BARRICADE = 2, SCORCH = 3, ENFLAME = 4, JAWS_AND_CLAWS = 5}
enum RedQueen {BOLSTER = 0, ARROGANCE = 1, ROYAL_STRIKE = 2, SNARKY = 3, SUMMON_GUARDS = 4, SIEZE_HER = 5, ENRAGE = 6, ROYAL_TOILET_PAPER = 7, OFF_WITH_YOUR_HEAD = 8}

var whiteRabbitActions = [
	[3, 0, 0, false, "Whack", "Deals 3 Thirst.", "res://Assets/Sprites/Biscuits/Nice.png", WhiteRabbit.WHACK],
	[0, 3, 0, true, "Parry", "Adds 3 Defense.", "res://Assets/Sprites/Biscuits/Nice.png", WhiteRabbit.PARRY],
	[0, 0, 2, true, "Boon", "Gain 1 Thirst Power.", "res://Assets/Sprites/Biscuits/Nice.png", WhiteRabbit.BOON], 
	[0, 0, 3, true, "Buff", "Gain 1 Defense Power.", "res://Assets/Sprites/Biscuits/Nice.png", WhiteRabbit.BUFF],
	[0, 0, 1, true, "I'm Late!", "Gain 1 Thirst Power every turn.", "res://Assets/Sprites/Biscuits/Nice.png", WhiteRabbit.IM_LATE]
]
var madHatterActions = [
	[5, 0, 0, false, "Batter", "Deals 5 Thirst.", "res://Assets/Sprites/Biscuits/Nice.png", MadHatter.BATTER],
	[0, 5, 0, true, "Rebuff", "Adds 5 Defense.", "res://Assets/Sprites/Biscuits/Nice.png", MadHatter.REBUFF],
	[0, 0, 2, true, "Empower", "Gain 1 Thirst Power.", "res://Assets/Sprites/Biscuits/Nice.png", MadHatter.EMPOWER],
	[0, 0, 3, true, "Bonanza", "Gain 1 Defense Power.", "res://Assets/Sprites/Biscuits/Nice.png", MadHatter.BONANZA],
	[0, 0, 4, false, "Batter?", "Deals a random amount of Thirst. Between 3 to 10.", "res://Assets/Sprites/Biscuits/Nice.png", MadHatter.BATTER_R],
	[0, 0, 5, true, "Rebuff?", "Adds a random amount of Defense. Between 3 to 10.", "res://Assets/Sprites/Biscuits/Nice.png", MadHatter.REBUFF_R],
	[0, 0, 6, true, "Empower?", "Gain a random amount of Thirst Power. Between 0 to 3", "res://Assets/Sprites/Biscuits/Nice.png", MadHatter.EMPOWER_R],
	[0, 0, 7, true, "Bonanza?", "Gain a random amount of Defense Power. Between 0 to 3", "res://Assets/Sprites/Biscuits/Nice.png", MadHatter.BONANZA_R],
	[0, 0, 8, false, "Spike", "Spikes your tea. You must play a random amount of biscuits on your next turn.", "res://Assets/Sprites/Biscuits/Nice.png", MadHatter.SPIKE],
	[0, 0, 1, true, "Intoxicate", "Becomes intoxicated. Everything is random!", "res://Assets/Sprites/Biscuits/Nice.png", MadHatter.INTOXICATE],
]
var cheshireCatActions = [
	[5, 0, 0, false, "Scratch", "Deals 5 Thirst.", "res://Assets/Sprites/Biscuits/Nice.png", CheshireCat.SCRATCH],
	[0, 5, 0, true, "Paw", "Adds 5 Defense.", "res://Assets/Sprites/Biscuits/Nice.png", CheshireCat.PAW],
	[10, 0, 0, false, "Bite", "Deals 10 Thirst.", "res://Assets/Sprites/Biscuits/Nice.png", CheshireCat.BITE],
	[0, 0, 9, false, "Maim", "Lose 1 Thirst Power. Lose 1 Defense Power.", "res://Assets/Sprites/Biscuits/Nice.png", CheshireCat.MAIM],
	[0, 0, 10, false, "Curse", "Adds a useless biscuit to your discard pile.", "res://Assets/Sprites/Biscuits/Nice.png", CheshireCat.CURSE],
	[0, 0, 1, true, "Vanish", "Becomes invisible.", "res://Assets/Sprites/Biscuits/Nice.png", CheshireCat.VANISH],
]
var jabberwockyActions = [
	[5, 0, 0, false, "Swipe", "Deals 5 Thirst.", "res://Assets/Sprites/Biscuits/Nice.png", Jabberwocky.SWIPE],
	[12, 0, 0, false, "Slash", "Deals 12 Thirst.", "res://Assets/Sprites/Biscuits/Nice.png", Jabberwocky.SLASH],
	[0, 12, 0, true, "Barricade", "Adds 12 Defense.", "res://Assets/Sprites/Biscuits/Nice.png", Jabberwocky.BARRICADE],
	[0, 0, 11, false, "Scorch", "Set's your tea ablaze. The next biscuit you dunk in it will sink.", "res://Assets/Sprites/Biscuits/Nice.png", Jabberwocky.SCORCH],
	[0, 0, 1, true, "Enflame", "Becomes enraged. Gains 1 Thirst Power every time you apply Thirst to this enemy", "res://Assets/Sprites/Biscuits/Nice.png", Jabberwocky.ENFLAME],
	[20, 0, 0, false, "Jaws and Claws", "Deals 20 Thirst.", "res://Assets/Sprites/Biscuits/Nice.png", Jabberwocky.JAWS_AND_CLAWS],
]
var redQueenActions = [
		[0, 15, 0, true, "Bolster", "Add 15 Defense.", "res://Assets/Sprites/Biscuits/Nice.png", RedQueen.BOLSTER],
		[0, 0, 12, true, "Arrogance", "Gain 3 Thirst Power.", "res://Assets/Sprites/Biscuits/Nice.png", RedQueen.ARROGANCE],
		[15, 0, 0, false, "Royal Strike", "Deals 15 Thirst.", "res://Assets/Sprites/Biscuits/Nice.png", RedQueen.ROYAL_STRIKE],
		[0, 0, 13, false, "Snarky", "You lose 1 Defense Power.", "res://Assets/Sprites/Biscuits/Nice.png", RedQueen.SNARKY],
		[0, 0, 16, true, "Summon Guards", "Summons the guards.", "res://Assets/Sprites/Biscuits/Nice.png", RedQueen.SUMMON_GUARDS],
		[0, 0, 17, false, "SIEZE HER!", "Deals 3 Thirst for every guard.", "res://Assets/Sprites/Biscuits/Nice.png", RedQueen.SIEZE_HER],
		[0, 0, 14, true, "Enrage", "Becomes angry. Gair 5 Thirst Power. Do not mess with her.", "res://Assets/Sprites/Biscuits/Nice.png", RedQueen.ENRAGE],
		[0, 0, 15, true, "Royal Toilet Paper", "Heals 10 Tea.", "res://Assets/Sprites/Biscuits/Nice.png", RedQueen.ROYAL_TOILET_PAPER],
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
	if actionCount == 0:
		actions.append(cheshireCatActions[CheshireCat.SCRATCH])
		actions.append(cheshireCatActions[CheshireCat.PAW])
	else:
		match lastAction:
			CheshireCat.SCRATCH:
				if value <= 0.25:
					actions.append(cheshireCatActions[CheshireCat.BITE])
				elif value <= 0.5:
					actions.append(cheshireCatActions[CheshireCat.CURSE])
				elif value <= 0.75:
					actions.append(cheshireCatActions[CheshireCat.MAIM])
				else:
					actions.append(cheshireCatActions[CheshireCat.VANISH])
			CheshireCat.PAW:
				if value <= 0.25:
					actions.append(cheshireCatActions[CheshireCat.BITE])
				elif value <= 0.5:
					actions.append(cheshireCatActions[CheshireCat.CURSE])
				elif value <= 0.75:
					actions.append(cheshireCatActions[CheshireCat.MAIM])
				else:
					actions.append(cheshireCatActions[CheshireCat.VANISH])
			CheshireCat.BITE:
				if value <= 0.25:
					actions.append(cheshireCatActions[CheshireCat.SCRATCH])
					actions.append(cheshireCatActions[CheshireCat.PAW])
				elif value <= 0.5:
					actions.append(cheshireCatActions[CheshireCat.CURSE])
				elif value <= 0.75:
					actions.append(cheshireCatActions[CheshireCat.MAIM])
				else:
					actions.append(cheshireCatActions[CheshireCat.VANISH])
			CheshireCat.MAIM:
				if value <= 0.5:
					actions.append(cheshireCatActions[CheshireCat.SCRATCH])
					actions.append(cheshireCatActions[CheshireCat.PAW])
				else:
					actions.append(cheshireCatActions[CheshireCat.BITE])
			CheshireCat.CURSE:
				if value <= 0.5:
					actions.append(cheshireCatActions[CheshireCat.SCRATCH])
					actions.append(cheshireCatActions[CheshireCat.PAW])
				else:
					actions.append(cheshireCatActions[CheshireCat.BITE])
			CheshireCat.VANISH:
				if value <= 0.5:
					actions.append(cheshireCatActions[CheshireCat.SCRATCH])
					actions.append(cheshireCatActions[CheshireCat.PAW])
				else:
					actions.append(cheshireCatActions[CheshireCat.BITE])
	return actions
	
func jabberwocky(lastAction : int, value : float) -> Array[Array]:
	var actions : Array[Array]
	
	if actionCount == 0:
		actions.append(jabberwockyActions[Jabberwocky.SWIPE])
		actions.append(jabberwockyActions[Jabberwocky.SCORCH])
	elif actionCount == 6:
		actions.append(jabberwockyActions[Jabberwocky.ENFLAME])
	elif specialState:
		match lastAction:
			Jabberwocky.ENFLAME:
				actions.append(jabberwockyActions[Jabberwocky.SLASH])
			Jabberwocky.SLASH:
				if value <= 0.7:
					actions.append(jabberwockyActions[Jabberwocky.SWIPE])
					actions.append(jabberwockyActions[Jabberwocky.BARRICADE])
				else:
					actions.append(jabberwockyActions[Jabberwocky.JAWS_AND_CLAWS])
			Jabberwocky.JAWS_AND_CLAWS:
				actions.append(jabberwockyActions[Jabberwocky.SWIPE])
				actions.append(jabberwockyActions[Jabberwocky.BARRICADE])
			Jabberwocky.SWIPE:
				if value <= 0.7:
					actions.append(jabberwockyActions[Jabberwocky.JAWS_AND_CLAWS])
				else:
					actions.append(jabberwockyActions[Jabberwocky.SLASH])
			Jabberwocky.BARRICADE:
				if value <= 0.7:
					actions.append(jabberwockyActions[Jabberwocky.JAWS_AND_CLAWS])
				else:
					actions.append(jabberwockyActions[Jabberwocky.SLASH])
	else:
		match lastAction:
			Jabberwocky.SCORCH:
				if value <= 0.5:
					actions.append(jabberwockyActions[Jabberwocky.SLASH])
				else:
					actions.append(jabberwockyActions[Jabberwocky.SWIPE])
					actions.append(jabberwockyActions[Jabberwocky.BARRICADE])
			Jabberwocky.SLASH:
				if value <= 0.5:
					actions.append(jabberwockyActions[Jabberwocky.SWIPE])
					actions.append(jabberwockyActions[Jabberwocky.SCORCH])
				else:
					actions.append(jabberwockyActions[Jabberwocky.SWIPE])
					actions.append(jabberwockyActions[Jabberwocky.BARRICADE])
			Jabberwocky.SWIPE:
				print("Bug")
				actions.append(jabberwockyActions[Jabberwocky.SLASH])
			Jabberwocky.BARRICADE:
				if value <= 0.5:
					actions.append(jabberwockyActions[Jabberwocky.SLASH])
				else:
					actions.append(jabberwockyActions[Jabberwocky.SWIPE])
					actions.append(jabberwockyActions[Jabberwocky.SCORCH])
	
	return actions
	
func red_queen(lastAction : int, value : float) -> Array[Array]:
	var actions : Array[Array]
	
	if enemyTeacup.teaLevel <= 50 and stateSpace.get(RedQueen.ENRAGE).get(1):
		actions.append(redQueenActions[RedQueen.ENRAGE])
	elif specialState:
		match lastAction:
			RedQueen.ENRAGE:
				actions.append(redQueenActions[RedQueen.SUMMON_GUARDS])
			RedQueen.ROYAL_STRIKE:
				if value <= 0.7:
					actions.append(redQueenActions[RedQueen.SUMMON_GUARDS])
				else:
					actions.append(redQueenActions[RedQueen.OFF_WITH_YOUR_HEAD])
			RedQueen.SNARKY:
				if value <= 0.7:
					actions.append(redQueenActions[RedQueen.SUMMON_GUARDS])
				else:
					actions.append(redQueenActions[RedQueen.OFF_WITH_YOUR_HEAD])
			RedQueen.OFF_WITH_YOUR_HEAD:
				actions.append(redQueenActions[RedQueen.ROYAL_TOILET_PAPER])
			RedQueen.SUMMON_GUARDS:
				if value <= 0.8:
					actions.append(redQueenActions[RedQueen.OFF_WITH_YOUR_HEAD])
				elif value <= 0.9:
					actions.append(redQueenActions[RedQueen.ROYAL_STRIKE])
					actions.append(redQueenActions[RedQueen.SNARKY])
				else:
					actions.append(redQueenActions[RedQueen.ROYAL_TOILET_PAPER])
			RedQueen.ROYAL_TOILET_PAPER:
				actions.append(redQueenActions[RedQueen.ROYAL_STRIKE])
				actions.append(redQueenActions[RedQueen.SNARKY])
			
	else:
		match lastAction:
			RedQueen.BOLSTER:
				if stateSpace.get(RedQueen.BOLSTER).get(0) >= 2 or stateSpace.get(RedQueen.ARROGANCE).get(0) >= 2:
					if value <= 0.8:
						actions.append(redQueenActions[RedQueen.ROYAL_STRIKE])
						actions.append(redQueenActions[RedQueen.SNARKY])
					else:
						actions.append(redQueenActions[RedQueen.SUMMON_GUARDS])
				else:
					if value <= 0.4:
						actions.append(redQueenActions[RedQueen.BOLSTER])
						actions.append(redQueenActions[RedQueen.ARROGANCE])
					elif value <= 0.5:
						actions.append(redQueenActions[RedQueen.SUMMON_GUARDS])
					else:
						actions.append(redQueenActions[RedQueen.ROYAL_STRIKE])
						actions.append(redQueenActions[RedQueen.SNARKY])
			RedQueen.ARROGANCE:
				if stateSpace.get(RedQueen.BOLSTER).get(0) >= 2 or stateSpace.get(RedQueen.ARROGANCE).get(0) >= 2:
					if value <= 0.8:
						actions.append(redQueenActions[RedQueen.ROYAL_STRIKE])
						actions.append(redQueenActions[RedQueen.SNARKY])
					else:
						actions.append(redQueenActions[RedQueen.SUMMON_GUARDS])
				else:
					if value <= 0.4:
						actions.append(redQueenActions[RedQueen.BOLSTER])
						actions.append(redQueenActions[RedQueen.ARROGANCE])
					elif value <= 0.5:
						actions.append(redQueenActions[RedQueen.SUMMON_GUARDS])
					else:
						actions.append(redQueenActions[RedQueen.ROYAL_STRIKE])
						actions.append(redQueenActions[RedQueen.SNARKY])
			RedQueen.ROYAL_STRIKE:
				if stateSpace.get(RedQueen.ROYAL_STRIKE).get(0) >= 2 or stateSpace.get(RedQueen.SNARKY).get(0) >= 2:
					if value <= 0.8:
						actions.append(redQueenActions[RedQueen.BOLSTER])
						actions.append(redQueenActions[RedQueen.ARROGANCE])
					else:
						actions.append(redQueenActions[RedQueen.SUMMON_GUARDS])
				else:
					if value <= 0.4:
						actions.append(redQueenActions[RedQueen.ROYAL_STRIKE])
						actions.append(redQueenActions[RedQueen.SNARKY])
					elif value <= 0.5:
						actions.append(redQueenActions[RedQueen.SUMMON_GUARDS])
					else:
						actions.append(redQueenActions[RedQueen.BOLSTER])
						actions.append(redQueenActions[RedQueen.ARROGANCE])
			RedQueen.SNARKY:
				if stateSpace.get(RedQueen.ROYAL_STRIKE).get(0) >= 2 or stateSpace.get(RedQueen.SNARKY).get(0) >= 2:
					if value <= 0.8:
						actions.append(redQueenActions[RedQueen.BOLSTER])
						actions.append(redQueenActions[RedQueen.ARROGANCE])
					else:
						actions.append(redQueenActions[RedQueen.SUMMON_GUARDS])
				else:
					if value <= 0.4:
						actions.append(redQueenActions[RedQueen.ROYAL_STRIKE])
						actions.append(redQueenActions[RedQueen.SNARKY])
					elif value <= 0.5:
						actions.append(redQueenActions[RedQueen.SUMMON_GUARDS])
					else:
						actions.append(redQueenActions[RedQueen.BOLSTER])
						actions.append(redQueenActions[RedQueen.ARROGANCE])
			RedQueen.SUMMON_GUARDS:
				actions.append(redQueenActions[RedQueen.BOLSTER])
				actions.append(redQueenActions[RedQueen.ARROGANCE])
	
	if redQueenGuardCount > 0:
		actions.append(redQueenActions[RedQueen.SIEZE_HER])
	
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

			actions = choose_actions(2)
		3:
			# Jabberwocky
			
			actions = choose_actions(3)
		4:
			# The Red Queen
			
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

func set_dialogue() -> void:
	match index:
		0:
			match dialogueCounter:
				0:
					deckManager.hand.draggingDisabled = true
					speak("Welcome to Biscuitland! I hope you didn't hit your head too hard on the way down. What do they call you?")
				1:
					speak("Alice! How novel. I don't think I've ever met an Alice before. Where are you from?")
				2:
					speak("Hm. I'm not so sure that place exists.")
				3:
					speak("Let me explain how things work around here.")
				4:
					speak("In Biscuitland, you will encounter many... interesting personalities.")
				5:
					speak("You will face each of them off in an epic biscuit battle,")
				6:
					speak("and may only proceed once each enemy has been defeated.")
				7:
					speak("You and the enemy each have a level of tea. If you, or the enemy, run out of tea, you perish. How sad.")
				8:
					speak("It follows that your aim is to deplete the enemy of his tea.")
				9:
					speak("The battle is played in turns. On your turn, you will play 3 of 5 biscuits.")
				10:
					speak("Each biscuit has a unique and wonderful effect.")
				11:
					speak("Hover over the biscuits in your hand to see what they do. Play biscuits by dragging and dropping them.")
				12:
					speak("Biscuits can be given to the enemy.")
				13:
					speak("For example, biscuits that inflict thirst and force your enemy to drink tea.")
				14:
					speak("They can also be given to yourself.")
				15:
					speak("For example, to increase your defense.")
				16:
					speak("Once you have played your biscuits, it is then the enemy's turn,")
				17:
					speak("and they will play up to three biscuits.")
				18:
					speak("You and the enemy both have a defense bar.")
				19:
					speak("This acts as a buffer, reducing the thirst inflicted by a biscuit by the defense level.")
				20:
					speak("Any excess thirst is then deducted from your tea. That make sense?")
				21:
					speak("Great.")
				22:
					speak("What was that?")
				23:
					speak("Where's the risk and excitement, you say?")
				24:
					speak("You've got a spine on you!")
				25:
					speak("I like it. Well, if you insist...")
				26:
					speak("Biscuits can be played as they are, or, you may choose to dip them in your tea.")
				27:
					speak("The benefit is that your biscuit's abilities are greatly intensified;")
				28:
					speak("the risk is that the biscuit may sink in the tea and be lost for the rest of the battle.")
				29:
					speak("The stakes are raised ever higher! I'm simply giddy with excitement!")
				30:
					speak("For your benefit, there is a thermometer beside your tea,")
				31:
					speak("which shows you the chance of your biscuits sinking in your tea.")
				32:
					speak("You can read, can't you?")
				33:
					speak("Excellent. The higher the level in the thermometer,")
				34:
					speak("the greater the chance of your biscuit sinking in the tea!")
				35:
					speak("Beware! If you sink all your biscuits, you'll have nothing to battle with!")
				36:
					speak("The fight will be over, and you will have perished a slow and embarrassing death!")
				37:
					speak("No, not really. We just send you back to the start. We aren't that frightful. Why are you so pale?")
				38:
					speak("May I offer you a biscuit? Does that make you feel better?")
				39:
					speak("Excellent. Let us continue.")
				40:
					speak("Now, some biscuits have lasting effects.")
				41:
					speak("These effects are called modifiers. Hover over a modifier to see what it does.")
				42:
					speak("The enemy also has modifiers. Hover over the enemy to see what they are.")
				43:
					speak("Are you following? Do you need a pen and paper?")
				44:
					speak("Oh bother, I left it in my other suit. Sorry. Oh, one more thing!")
				45:
					speak("Powerups increase the... well... power... of your biscuits.")
				46:
					speak("For example, a thirst powerup of one increases the thirst each attack biscuit inflicts by one.")
				47:
					speak("A defense powerup of two increases the defense of each defending biscuit by two. It's simple!")
				48:
					speak("What's that?")
				49:
					speak("You're afraid?")
				50:
					speak("Oh, that will not do, my dear!")
				51:
					speak("You must have the courage of a thousand biscuit soldiers,")
				52:
					speak("else you will never defeat the... well. You'll see.")
				53:
					speak("Let me help you out. How about we do battle together, first? I, as your friend and humble servant?")
				54:
					speak("You will? Excellent. Shall we begin?")
				55:
					deckManager.hand.draggingDisabled = false
					
		1:
			pass
		2:
			pass
		3:
			pass
		4:
			pass

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
		sfx.stream = hover
		sfx.play()
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
		sfx.stream = hover
		sfx.play()
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

func speak(text : String) -> void:
	dialogueCounter += 1
	dialogue.text = text
	dialogueTypewriterFinished = false
	dialogue.visible_characters = 0
	dialogueAnimation.play("appear")
	dialogueBox.disabled = false
	
	typewriterTimer.wait_time = 0.6
	typewriterTimer.start()

func hoverDialogue() -> void:
	hoveringDialogue = true
	
func unhoverDialogue() -> void:
	hoveringDialogue = false
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Click") and hoveringDialogue and dialogueTypewriterFinished:
		helperText.text = ""
		dialogue.text = ""
		dialogueAnimation.play("vanish")
		dialogueBox.disabled = false
		dialogueTimer.wait_time = 0.75
		dialogueTimer.start()

func _on_dialogue_timer_timeout() -> void:
	set_dialogue()

func _on_typewriter_timer_timeout() -> void:
	if dialogue.visible_characters == 0:
		typewriterTimer.wait_time = 0.03
	dialogue.visible_characters += 1
	
	typerwriterSound.stop()
	var index = randi_range(0, 2)
	match index:
		0:
			typerwriterSound.stream = pop1
		1:
			typerwriterSound.stream = pop2
		2:
			typerwriterSound.stream = pop3
	typerwriterSound.play()
	
	if len(dialogue.text) <= dialogue.visible_characters:
		dialogueTypewriterFinished = true
		typerwriterSound.playing = false
	else:
		typewriterTimer.start()
