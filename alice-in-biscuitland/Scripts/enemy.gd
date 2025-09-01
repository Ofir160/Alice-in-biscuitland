class_name Enemy
extends Node2D

const hover = preload("res://Assets/Audio/SFX/biscuitHover.ogg")
const unhover = preload("res://Assets/Audio/SFX/biscuitUnhover.ogg")

const pop1 = preload("res://Assets/Audio/SFX/pop 1.mp3")
const pop2 = preload("res://Assets/Audio/SFX/pop 2.mp3")
const pop3 = preload("res://Assets/Audio/SFX/pop 3.mp3")

@export var enemyTeacup : Teacup
var biscuits : Array[Biscuit]
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
@export var skipButton : TextureButton

@onready var below: AnimatedSprite2D = $Below
@onready var above: AnimatedSprite2D = $Above
@onready var guards: AnimatedSprite2D = $Guards

@export var sfx : AudioStreamPlayer2D
@export var skipTutorial : bool

var chosenActions : Array[Biscuit]
var index : int
var hovering : bool = false
var hoveringDialogue : bool = false
var dialogueCounter : int = 0
var dialogueTypewriterFinished : bool
var dialogueWaiting : bool

var defense : int
var attackPower : int
var defensePower : int

var goToDie : bool
var highlighted : bool
var inTutorial : bool

enum WhiteRabbit {WHACK = 1, PARRY = 2, BOON = 3, BUFF = 4, IM_LATE = 5}
enum MadHatter {BATTER = 6, REBUFF = 7, EMPOWER = 8, BONANZA = 9, BATTER_R = 10, REBUFF_R = 11, EMPOWER_R = 12, BONANZA_R = 13, SPIKE = 14, INTOXICATE = 15 }
enum CheshireCat {SCRATCH = 16, PAW = 17, BITE = 18, MAIM = 19, CURSE = 20, VANISH = 21}
enum Jabberwocky {SWIPE = 22, SLASH = 23, BARRICADE = 24, SCORCH = 25, ENFLAME = 26, JAWS_AND_CLAWS = 27}
enum RedQueen {BOLSTER = 28, ARROGANCE = 29, ROYAL_STRIKE = 30, SNARKY = 31, SUMMON_GUARDS = 32, SIEZE_HER = 33, ENRAGE = 34, ROYAL_TOILET_PAPER = 35, OFF_WITH_YOUR_HEAD = 36}

var stateSpace : Dictionary[int, Array]
# The key is the index of the move.
# The array contains the number of times the move is used consecutively and how many times its been used

var specialState : bool
var actionCount : int
var redQueenGuardCount : int

func set_sprite() -> void:
	match index:
		0:
			# White Rabbit 
			
			below.play("WR")
			above.modulate = Color(0, 0, 0, 0)
		1:
			# Mad Hatter
			
			below.play("MH")
			above.modulate = Color(0, 0, 0, 0)
		2:
			#Cheshire Cat
			
			above.play("CC")
			below.modulate = Color(0, 0, 0, 0)
		3:
			# Jabberwocky
			below.play("JB")
			above.modulate = Color(0, 0, 0, 0)
		4:
			# Red Queen
			
			below.play("RQ")
			above.modulate = Color(0, 0, 0, 0)

func take_thirst(_thirst : int) -> void:
	var damage : int = _thirst
	if _thirst <= defense:
		defense = defense - _thirst
	else:
		damage = _thirst - defense
		defense = 0
	enemyTeacup.sip(damage)

func add_defense(_defense : int) -> void:
	defense += _defense

func update_state_space(actions : Array[Biscuit]) -> void:
	for i in len(actions):
		var biscuit = actions.get(i)
		var key : int = biscuit.index
		var data : Array = [stateSpace.get(key).get(0) + 1, stateSpace.get(key).get(1) + 1]
		stateSpace.set(key, data)
		for currentKey in stateSpace.keys():
			if key != currentKey:
				var newData : Array = [0, stateSpace.get(currentKey).get(1)]
				stateSpace.set(currentKey, newData)

func initialize_state_space() -> void:
	match index:
		0:
			for key in WhiteRabbit.keys():
				stateSpace.set(WhiteRabbit.get(key), [0, 0])
		1:
			for key in MadHatter.keys():
				stateSpace.set(MadHatter.get(key), [0, 0])
		2:
			for key in CheshireCat.keys():
				stateSpace.set(CheshireCat.get(key), [0, 0])
		3:
			for key in Jabberwocky.keys():
				stateSpace.set(Jabberwocky.get(key), [0, 0])
		4:
			for key in RedQueen.keys():
				stateSpace.set(RedQueen.get(key), [0, 0])

func get_biscuit_actions(actionIndex : Array[int]) -> Array[Biscuit]:
	var actions : Array[Biscuit]
	
	for index in actionIndex:
		actions.append(GameManager.get_enemy_biscuit(index))
	
	return actions

func white_rabbit(lastAction : int, value : float) -> Array[Biscuit]:
	var actionIndex : Array[int]
	if actionCount == 0:
		actionIndex.append(WhiteRabbit.WHACK)
	elif actionCount == 1:
		actionIndex.append(WhiteRabbit.WHACK)
	elif actionCount == 2:
		actionIndex.append(WhiteRabbit.BOON)
	elif actionCount == 3:
		actionIndex.append(WhiteRabbit.WHACK)
	elif actionCount == 4:
		actionIndex.append(WhiteRabbit.IM_LATE)
	else:
		match lastAction:
			WhiteRabbit.WHACK:
				if stateSpace.get(WhiteRabbit.WHACK).get(0) >= 3:
					actionIndex.append(WhiteRabbit.PARRY)
				else:
					if value <= 0.5:
						actionIndex.append(WhiteRabbit.PARRY)
					else:
						actionIndex.append(WhiteRabbit.WHACK)
			WhiteRabbit.PARRY:
				if stateSpace.get(WhiteRabbit.BUFF).get(1) >= 1:
					actionIndex.append(WhiteRabbit.WHACK)
				else:
					if value <= 0.5:
						actionIndex.append(WhiteRabbit.WHACK)
					else:
						actionIndex.append(WhiteRabbit.BUFF)
			WhiteRabbit.BOON:
				actionIndex.append(WhiteRabbit.WHACK)
			WhiteRabbit.BUFF:
				actionIndex.append(WhiteRabbit.PARRY)
			WhiteRabbit.IM_LATE:
				actionIndex.append(WhiteRabbit.WHACK)
					
	return get_biscuit_actions(actionIndex)

func mad_hatter(lastAction : int, value : float) -> Array[Biscuit]:
	var actionIndex : Array[int]
	
	if actionCount == 0:
		actionIndex.append(MadHatter.BATTER)
	elif actionCount == 1:
		actionIndex.append(MadHatter.EMPOWER)
		actionIndex.append(MadHatter.BONANZA)
	elif actionCount == 2:
		actionIndex.append(MadHatter.REBUFF)
	elif actionCount == 3:
		actionIndex.append(MadHatter.SPIKE)
		actionIndex.append(MadHatter.BATTER)
	elif actionCount == 4:
		actionIndex.append(MadHatter.INTOXICATE)
	elif actionCount == 5:
		actionIndex.append(MadHatter.BATTER_R)
	else:
		match lastAction:
			MadHatter.BATTER_R:
				if stateSpace.get(MadHatter.BATTER_R).get(0) >= 2:
					if value <= 0.4:
						actionIndex.append(MadHatter.REBUFF_R)
					elif value <= 0.8:
						actionIndex.append(MadHatter.EMPOWER_R)
						actionIndex.append(MadHatter.BONANZA_R)
					else:
						actionIndex.append(MadHatter.SPIKE)
						actionIndex.append(MadHatter.BATTER_R)
				else:
					if value <= 0.3:
						actionIndex.append(MadHatter.BATTER_R)
					elif value <= 0.6:
						actionIndex.append(MadHatter.REBUFF_R)
					elif value <= 0.9:
						actionIndex.append(MadHatter.EMPOWER_R)
						actionIndex.append(MadHatter.BONANZA_R)
					else:
						actionIndex.append(MadHatter.SPIKE)
						actionIndex.append(MadHatter.BATTER_R)
			MadHatter.EMPOWER_R:
				if value <= 0.2:
					actionIndex.append(MadHatter.SPIKE)
					actionIndex.append(MadHatter.BATTER_R)
				elif value <= 0.6:
					actionIndex.append(MadHatter.BATTER_R)
				else:
					actionIndex.append(MadHatter.REBUFF_R)
			MadHatter.BONANZA_R:
				if value <= 0.2:
					actionIndex.append(MadHatter.SPIKE)
					actionIndex.append(MadHatter.BATTER_R)
				elif value <= 0.6:
					actionIndex.append(MadHatter.BATTER_R)
				else:
					actionIndex.append(MadHatter.REBUFF_R)
			MadHatter.REBUFF_R:
				if value <= 0.5:
					actionIndex.append(MadHatter.BATTER_R)
				else:
					actionIndex.append(MadHatter.BONANZA_R)
					actionIndex.append(MadHatter.EMPOWER_R)
			MadHatter.SPIKE:
				actionIndex.append(MadHatter.BATTER_R)
	return get_biscuit_actions(actionIndex)

func cheshire_cat(lastAction : int, value : float) -> Array[Biscuit]:
	var actionIndex : Array[Array]
	if actionCount == 0:
		actionIndex.append(CheshireCat.SCRATCH)
		actionIndex.append(CheshireCat.PAW)
	else:
		match lastAction:
			CheshireCat.SCRATCH:
				if value <= 0.25:
					actionIndex.append(CheshireCat.BITE)
				elif value <= 0.5:
					actionIndex.append(CheshireCat.CURSE)
				elif value <= 0.75:
					actionIndex.append(CheshireCat.MAIM)
				else:
					actionIndex.append(CheshireCat.VANISH)
			CheshireCat.PAW:
				if value <= 0.25:
					actionIndex.append(CheshireCat.BITE)
				elif value <= 0.5:
					actionIndex.append(CheshireCat.CURSE)
				elif value <= 0.75:
					actionIndex.append(CheshireCat.MAIM)
				else:
					actionIndex.append(CheshireCat.VANISH)
			CheshireCat.BITE:
				if value <= 0.25:
					actionIndex.append(CheshireCat.SCRATCH)
					actionIndex.append(CheshireCat.PAW)
				elif value <= 0.5:
					actionIndex.append(CheshireCat.CURSE)
				elif value <= 0.75:
					actionIndex.append(CheshireCat.MAIM)
				else:
					actionIndex.append(CheshireCat.VANISH)
			CheshireCat.MAIM:
				if value <= 0.5:
					actionIndex.append(CheshireCat.SCRATCH)
					actionIndex.append(CheshireCat.PAW)
				else:
					actionIndex.append(CheshireCat.BITE)
			CheshireCat.CURSE:
				if value <= 0.5:
					actionIndex.append(CheshireCat.SCRATCH)
					actionIndex.append(CheshireCat.PAW)
				else:
					actionIndex.append(CheshireCat.BITE)
			CheshireCat.VANISH:
				if value <= 0.5:
					actionIndex.append(CheshireCat.SCRATCH)
					actionIndex.append(CheshireCat.PAW)
				else:
					actionIndex.append(CheshireCat.BITE)
	return GameManager.get_enemy_biscuit(actionIndex)
	
func jabberwocky(lastAction : int, value : float) -> Array[Biscuit]:
	var actionIndex : Array[Array]
	
	if actionCount == 0:
		actionIndex.append(Jabberwocky.SWIPE)
		actionIndex.append(Jabberwocky.SCORCH)
	elif actionCount == 6:
		actionIndex.append(Jabberwocky.ENFLAME)
	elif specialState:
		match lastAction:
			Jabberwocky.ENFLAME:
				actionIndex.append(Jabberwocky.SLASH)
			Jabberwocky.SLASH:
				if value <= 0.7:
					actionIndex.append(Jabberwocky.SWIPE)
					actionIndex.append(Jabberwocky.BARRICADE)
				else:
					actionIndex.append(Jabberwocky.JAWS_AND_CLAWS)
			Jabberwocky.JAWS_AND_CLAWS:
				actionIndex.append(Jabberwocky.SWIPE)
				actionIndex.append(Jabberwocky.BARRICADE)
			Jabberwocky.SWIPE:
				if value <= 0.7:
					actionIndex.append(Jabberwocky.JAWS_AND_CLAWS)
				else:
					actionIndex.append(Jabberwocky.SLASH)
			Jabberwocky.BARRICADE:
				if value <= 0.7:
					actionIndex.append(Jabberwocky.JAWS_AND_CLAWS)
				else:
					actionIndex.append(Jabberwocky.SLASH)
	else:
		match lastAction:
			Jabberwocky.SCORCH:
				if value <= 0.5:
					actionIndex.append(Jabberwocky.SLASH)
				else:
					actionIndex.append(Jabberwocky.SWIPE)
					actionIndex.append(Jabberwocky.BARRICADE)
			Jabberwocky.SLASH:
				if value <= 0.5:
					actionIndex.append(Jabberwocky.SWIPE)
					actionIndex.append(Jabberwocky.SCORCH)
				else:
					actionIndex.append(Jabberwocky.SWIPE)
					actionIndex.append(Jabberwocky.BARRICADE)
			Jabberwocky.SWIPE:
				print("Bug")
				actionIndex.append(Jabberwocky.SLASH)
			Jabberwocky.BARRICADE:
				if value <= 0.5:
					actionIndex.append(Jabberwocky.SLASH)
				else:
					actionIndex.append(Jabberwocky.SWIPE)
					actionIndex.append(Jabberwocky.SCORCH)
	
	return GameManager.get_enemy_biscuit(actionIndex)
	
func red_queen(lastAction : int, value : float) -> Array[Biscuit]:
	var actionIndex : Array[Array]
	
	if enemyTeacup.teaLevel <= 50 and stateSpace.get(RedQueen.ENRAGE).get(1):
		actionIndex.append(RedQueen.ENRAGE)
	elif specialState:
		match lastAction:
			RedQueen.ENRAGE:
				if redQueenGuardCount >= 3:
					actionIndex.append(RedQueen.ROYAL_STRIKE)
					actionIndex.append(RedQueen.SNARKY)
				else:
					actionIndex.append(RedQueen.SUMMON_GUARDS)
			RedQueen.ROYAL_STRIKE:
				if redQueenGuardCount >= 3:
					actionIndex.append(RedQueen.OFF_WITH_YOUR_HEAD)
				else:
					if value <= 0.7:
						actionIndex.append(RedQueen.SUMMON_GUARDS)
					else:
						actionIndex.append(RedQueen.OFF_WITH_YOUR_HEAD)
			RedQueen.SNARKY:
				if redQueenGuardCount >= 3:
					actionIndex.append(RedQueen.OFF_WITH_YOUR_HEAD)
				else:
					if value <= 0.7:
						actionIndex.append(RedQueen.SUMMON_GUARDS)
					else:
						actionIndex.append(RedQueen.OFF_WITH_YOUR_HEAD)
			RedQueen.OFF_WITH_YOUR_HEAD:
				actionIndex.append(RedQueen.ROYAL_TOILET_PAPER)
			RedQueen.SUMMON_GUARDS:
				if value <= 0.8:
					actionIndex.append(RedQueen.OFF_WITH_YOUR_HEAD)
				elif value <= 0.9:
					actionIndex.append(RedQueen.ROYAL_STRIKE)
					actionIndex.append(RedQueen.SNARKY)
				else:
					actionIndex.append(RedQueen.ROYAL_TOILET_PAPER)
			RedQueen.ROYAL_TOILET_PAPER:
				actionIndex.append(RedQueen.ROYAL_STRIKE)
				actionIndex.append(RedQueen.SNARKY)
			
	else:
		match lastAction:
			RedQueen.BOLSTER:
				if stateSpace.get(RedQueen.BOLSTER).get(0) >= 2 or stateSpace.get(RedQueen.ARROGANCE).get(0) >= 2:
					if redQueenGuardCount >= 3:
						actionIndex.append(RedQueen.ROYAL_STRIKE)
						actionIndex.append(RedQueen.SNARKY)
					else:
						if value <= 0.8:
							actionIndex.append(RedQueen.ROYAL_STRIKE)
							actionIndex.append(RedQueen.SNARKY)
						else:
							actionIndex.append(RedQueen.SUMMON_GUARDS)
				else:
					if redQueenGuardCount >= 3:
						if value <= 0.45:
							actionIndex.append(RedQueen.BOLSTER)
							actionIndex.append(RedQueen.ARROGANCE)
						else:
							actionIndex.append(RedQueen.ROYAL_STRIKE)
							actionIndex.append(RedQueen.SNARKY)
					else:
						if value <= 0.4:
							actionIndex.append(RedQueen.BOLSTER)
							actionIndex.append(RedQueen.ARROGANCE)
						elif value <= 0.5:
							actionIndex.append(RedQueen.SUMMON_GUARDS)
						else:
							actionIndex.append(RedQueen.ROYAL_STRIKE)
							actionIndex.append(RedQueen.SNARKY)
			RedQueen.ARROGANCE:
				if stateSpace.get(RedQueen.BOLSTER).get(0) >= 2 or stateSpace.get(RedQueen.ARROGANCE).get(0) >= 2:
					if redQueenGuardCount >= 3:
						actionIndex.append(RedQueen.ROYAL_STRIKE)
						actionIndex.append(RedQueen.SNARKY)
					else:
						if value <= 0.8:
							actionIndex.append(RedQueen.ROYAL_STRIKE)
							actionIndex.append(RedQueen.SNARKY)
						else:
							actionIndex.append(RedQueen.SUMMON_GUARDS)
				else:
					if redQueenGuardCount >= 3:
						if value <= 0.45:
							actionIndex.append(RedQueen.BOLSTER)
							actionIndex.append(RedQueen.ARROGANCE)
						else:
							actionIndex.append(RedQueen.ROYAL_STRIKE)
							actionIndex.append(RedQueen.SNARKY)
					else:
						if value <= 0.4:
							actionIndex.append(RedQueen.BOLSTER)
							actionIndex.append(RedQueen.ARROGANCE)
						elif value <= 0.5:
							actionIndex.append(RedQueen.SUMMON_GUARDS)
						else:
							actionIndex.append(RedQueen.ROYAL_STRIKE)
							actionIndex.append(RedQueen.SNARKY)
			RedQueen.ROYAL_STRIKE:
				if stateSpace.get(RedQueen.ROYAL_STRIKE).get(0) >= 2 or stateSpace.get(RedQueen.SNARKY).get(0) >= 2:
					if redQueenGuardCount >= 3:
						actionIndex.append(RedQueen.BOLSTER)
						actionIndex.append(RedQueen.ARROGANCE)
					else:
						if value <= 0.8:
							actionIndex.append(RedQueen.BOLSTER)
							actionIndex.append(RedQueen.ARROGANCE)
						else:
							actionIndex.append(RedQueen.SUMMON_GUARDS)
				else:
					if redQueenGuardCount >= 3:
						if value <= 0.45:
							actionIndex.append(RedQueen.ROYAL_STRIKE)
							actionIndex.append(RedQueen.SNARKY)
						else:
							actionIndex.append(RedQueen.BOLSTER)
							actionIndex.append(RedQueen.ARROGANCE)
					else:
						if value <= 0.4:
							actionIndex.append(RedQueen.ROYAL_STRIKE)
							actionIndex.append(RedQueen.SNARKY)
						elif value <= 0.5:
							actionIndex.append(RedQueen.SUMMON_GUARDS)
						else:
							actionIndex.append(RedQueen.BOLSTER)
							actionIndex.append(RedQueen.ARROGANCE)
			RedQueen.SNARKY:
				if stateSpace.get(RedQueen.ROYAL_STRIKE).get(0) >= 2 or stateSpace.get(RedQueen.SNARKY).get(0) >= 2:
					if redQueenGuardCount >= 3:
						actionIndex.append(RedQueen.BOLSTER)
						actionIndex.append(RedQueen.ARROGANCE)
					else:
						if value <= 0.8:
							actionIndex.append(RedQueen.BOLSTER)
							actionIndex.append(RedQueen.ARROGANCE)
						else:
							actionIndex.append(RedQueen.SUMMON_GUARDS)
				else:
					if redQueenGuardCount >= 3:
						if value <= 0.45:
							actionIndex.append(RedQueen.ROYAL_STRIKE)
							actionIndex.append(RedQueen.SNARKY)
						else:
							actionIndex.append(RedQueen.BOLSTER)
							actionIndex.append(RedQueen.ARROGANCE)
					else:
						if value <= 0.4:
							actionIndex.append(RedQueen.ROYAL_STRIKE)
							actionIndex.append(RedQueen.SNARKY)
						elif value <= 0.5:
							actionIndex.append(RedQueen.SUMMON_GUARDS)
						else:
							actionIndex.append(RedQueen.BOLSTER)
							actionIndex.append(RedQueen.ARROGANCE)
			RedQueen.SUMMON_GUARDS:
				actionIndex.append(RedQueen.BOLSTER)
				actionIndex.append(RedQueen.ARROGANCE)
	
	if redQueenGuardCount > 0:
		actionIndex.append(RedQueen.SIEZE_HER)
	
	return GameManager.get_enemy_biscuit()

func choose_actions(index : int) -> Array[Biscuit]:
	var actions : Array[Biscuit]
	
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
	var actions : Array[Biscuit]
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
		var action : Biscuit = actions.get(i)
		
		GameManager.set_biscuit(biscuit, action)
	
	biscuits.get(0).update_sprites()
	biscuits.get(1).update_sprites()
	biscuits.get(2).update_sprites()
	biscuits.get(0).modulate = Color(1, 1, 1, 1)
	biscuits.get(1).modulate = Color(1, 1, 1, 1)
	biscuits.get(2).modulate = Color(1, 1, 1, 1)
	chosenActions = actions

func get_actions() -> Array[Biscuit]:
	if len(chosenActions) == 3:
		var biscuit1Animation = "Play Biscuits Enemy1" if chosenActions.get(0).enemyPlayable else "Play Biscuits Player1"
		$AnimationPlayer1.play(biscuit1Animation)
		var biscuit2Animation = "Play Biscuits Enemy2" if chosenActions.get(1).enemyPlayable else "Play Biscuits Player2"
		$AnimationPlayer2.play(biscuit2Animation)
		var biscuit3Animation = "Play Biscuits Enemy3" if chosenActions.get(2).enemyPlayable else "Play Biscuits Player3"
		$AnimationPlayer3.play(biscuit3Animation)
	elif len(chosenActions) == 2:
		var biscuit1Animation = "Play Biscuits Enemy1" if chosenActions.get(0).enemyPlayable else "Play Biscuits Player1"
		$AnimationPlayer1.play(biscuit1Animation)
		var biscuit2Animation = "Play Biscuits Enemy2" if chosenActions.get(1).enemyPlayable else "Play Biscuits Player2"
		$AnimationPlayer2.play(biscuit2Animation)
	elif len(chosenActions) == 1:
		var biscuit1Animation = "Play Biscuits Enemy1" if chosenActions.get(0).enemyPlayable else "Play Biscuits Player1"
		$AnimationPlayer1.play(biscuit1Animation)
	return chosenActions

func set_dialogue() -> void:
	match index:
		0:
			if actionCount == 1:
				if not GameManager.playedTutorial:
					if skipTutorial:
						dialogueCounter = 55
					match dialogueCounter:
						0:
							inTutorial = true
							
							skipButton.disabled = false
							skipButton.modulate = Color(1, 1, 1, 1)
							
							deckManager.hand.draggingDisabled = true
							speak_start("Welcome to Biscuitland! I hope you didn't hit your head too hard on the way down. What do they call you?")
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
							inTutorial = false
							GameManager.playedTutorial = true
							finish_dialogue()
							
			elif actionCount == 3:
				match dialogueCounter:
					0:
						dialogueWaiting = true
						speak_start("Your getting the hang of this!")
					1:
						finish_dialogue()
		1:
			if actionCount == 1:
				dialogueWaiting = true
				match dialogueCounter:
					0:
						speak_start("Curiouser and curiouser...")
					1:
						finish_dialogue()
			
			elif actionCount == 3:
				dialogueWaiting = true
				match dialogueCounter:
					0:
						speak_start("Would you like some more tea?")
					1:
						finish_dialogue()
		
			elif actionCount == 5:
				dialogueWaiting = true
				match dialogueCounter:
					0:
						speak_start("It’s always tea time")
					1:
						finish_dialogue()
		2:
			if actionCount == 1:
				dialogueWaiting = true
				match dialogueCounter:
					0:
						speak_start("We’re all mad here...")
					1:
						finish_dialogue()
		
			elif actionCount == 2:
				dialogueWaiting = true
				match dialogueCounter:
					0:
						speak_start("Not all who wander are lost...")
					1:
						finish_dialogue()
		3:
			if actionCount == 1:
				dialogueWaiting = true
				match dialogueCounter:
					0:
						speak_start("*SCREECH*")
					1:
						finish_dialogue()
		
			elif actionCount == 3:
				dialogueWaiting = true
				match dialogueCounter:
					0:
						speak_start("*SCREECH*")
					1:
						finish_dialogue()
		4:
			if actionCount == 1:
				dialogueWaiting = true
				match dialogueCounter:
					0:
						speak_start("Come to play croquet?")
					1:
						finish_dialogue()
			
func finish_dialogue() -> void:
	dialogueWaiting = false
	dialogueCounter = 0
	dialogueAnimation.play("vanish")
	deckManager.hand.draggingDisabled = false

func attacking() -> bool:
	var result : bool
	for action in chosenActions:
		if GameManager.get_enemy_biscuit(action).thirst != 0:
			result = true
	return result

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
	eatAnimationBiscuit.texture = load(chosenActions.get(index).img)
	
	if onPlayer:
		eatAnimation.play("Player")
	else:
		eatAnimation.play("Enemy")

func init() -> void:
	
	biscuits.append($"Enemy Attack 1")
	biscuits.append($"Enemy Attack 2")
	biscuits.append($"Enemy Attack 3")
	
	set_sprite()
	initialize_state_space()

func speak_start(text : String) -> void:
	dialogueAnimation.play("appear")
	typewriterTimer.wait_time = 0.5
	typewriterTimer.start()
	dialogueTypewriterFinished = false
	dialogue.visible_characters = 0
	dialogueBox.disabled = false
	dialogue.text = text
	
func speak(text : String) -> void:
	_on_typewriter_timer_timeout()
	dialogueTypewriterFinished = false
	dialogue.visible_characters = 0
	dialogueBox.disabled = false
	dialogue.text = text

func hoverDialogue() -> void:
	hoveringDialogue = true
	
func unhoverDialogue() -> void:
	hoveringDialogue = false
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Click") and hoveringDialogue and dialogueTypewriterFinished:
		helperText.text = ""
		dialogue.text = ""
		dialogueBox.disabled = false
		dialogueCounter += 1
		if goToDie:
			on_die()
		else:
			set_dialogue()
	if highlighted:
		match index:
			0:
				below.play("WR S")
			1:
				if specialState:
					below.play("MH MS")
				else:
					below.play("MH S")
			2:
				if specialState:
					above.play("CC MS")
				else:
					above.play("CC S")
			3:
				if specialState:
					below.play("JB MS")
				else:
					below.play("JB S")
			4:
				if specialState:
					below.play("RQ MS")
				else:
					below.play("RQ S")
	else:
		match index:
			0:
				below.play("WR")
			1:
				if specialState:
					below.play("MH M")
				else:
					below.play("MH")
			2:
				if specialState:
					above.play("CC M")
				else:
					above.play("CC")
			3:
				if specialState:
					below.play("JB M")
				else:
					below.play("JB")
			4:
				if specialState:
					below.play("RQ M")
				else:
					below.play("RQ")

func _on_typewriter_timer_timeout() -> void:
	if dialogue.visible_characters == 0:
		typewriterTimer.wait_time = 0.015
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

func on_die() -> void:
	goToDie = true
	match index:
		0:
			match dialogueCounter:
				0:
					speak_start("I'm Late! I'm Late! Good Luck, Alice! I must go!")
				1:
					finish_dialogue()
					deckManager.battleManager.finish_fight()
		1:
			match dialogueCounter:
				0:
					speak_start("Fair travels, the path ahead is dangerous…")
				1:
					finish_dialogue()
					deckManager.battleManager.finish_fight()
		2:
			match dialogueCounter:
				0:
					speak_start("Collect what you can…use it wisely. Good luck, little human!")
				1:
					finish_dialogue()
					deckManager.battleManager.finish_fight()
		3:
			match dialogueCounter:
				0:
					speak_start("*ANGRY SCREECH*")
				1:
					finish_dialogue()
					deckManager.battleManager.finish_fight()
		4:
			match dialogueCounter:
				0:
					speak_start("WHAT IS THIS MADNESS!?")
				1:
					speak("BUT... BUT...")
				2:
					speak("I ALWAYS WIN!")
				3:
					speak("SHE CHEATED!")
				4:
					speak("GUARDS!")
				5:
					speak("OFF WITH HER HEAD!")
				6:
					finish_dialogue()
					deckManager.battleManager.finish_fight()

func on_play_biscuit() -> void:
	if dialogueWaiting:
		dialogueCounter += 1
		dialogueWaiting = false
		set_dialogue()

func _on_skip_button_pressed() -> void:
	skipButton.disabled = true
	skipButton.modulate = Color(0, 0, 0, 0)
	if inTutorial:
		dialogueCounter = 55
		set_dialogue()
