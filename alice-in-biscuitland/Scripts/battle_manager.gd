class_name BattleManager
extends Node

@onready var timer: Timer = $Timer
@onready var deckManager: DeckManager = $"Deck Manager"

@export var cardsToPlay : int
@export var teacup : Teacup
@export var enemyTeacup : Teacup
@export var player : Player
@export var enemy : Enemy

var enemyActions : Array[Array]
var actionProgress : int

var lostGame : bool
var wonGame : bool

func _ready() -> void:
	deckManager.init()
	start_fight()


func start_fight() -> void:
	enemy.index = GameManager.progress # Sets what enemy we are fighting
	deckManager.drawPile.drawPile = GameManager.currentDeck.duplicate()
	deckManager.drawPile.shuffle()
	deckManager.hand.TurnEnded.connect(end_player_turn)
	teacup.maxTea = 50
	teacup.reset_tea()
	player.defense = 0
	enemyTeacup.maxTea = enemy.get_health()
	enemyTeacup.reset_tea()
	enemy.defense = 0
	start_player_turn()


func start_player_turn() -> void:
	# Start the players turn
	player.defense = 0
	
	deckManager.hand.draw_cards(5)
	
	if player.has_state(1):
		deckManager.cardsToPlay = 5
	else:
		deckManager.cardsToPlay = cardsToPlay
	enemy.set_action()
	player.step_timers()


func end_player_turn() -> void:
	enemy.defense = 0
	enemyActions = []
	start_enemy_turn()


func start_enemy_turn() -> void:
	# Start the enemies turn
	
	enemyActions = enemy.get_actions() # Starts the animations
	
	timer.wait_time = 0.4
	timer.start()
			
func play_enemy_action() -> void:
	
	var action : Array = enemyActions.get(actionProgress)
	if player.has_state(2):
		player.take_dryness(action.get(0) * 2)
	else:
		player.take_dryness(action.get(0))
	enemy.add_defense(action.get(1))
	if teacup.check_tea():
		lose_fight()
	actionProgress += 1
	
	if actionProgress < len(enemyActions):
		timer.wait_time = 0.8
		timer.start()
	else:
		timer.wait_time = 0.8 # 0.8 is the time till the last card goes. So this must be bigger than 0.8
		timer.start()
	
func end_enemy_turn() -> void:
	start_player_turn()
	

func lose_fight() -> void:
	# Lost the fight
	if deckManager.hand.TurnEnded.is_connected(end_player_turn):
		deckManager.hand.TurnEnded.disconnect(end_player_turn)
	timer.wait_time = 0.5
	timer.start()
	lostGame = true


func win_fight() -> void:
	# Won the fight
	if deckManager.hand.TurnEnded.is_connected(end_player_turn):
		deckManager.hand.TurnEnded.disconnect(end_player_turn)
	timer.wait_time = 0.5
	timer.start()
	wonGame = true


func play_biscuit(biscuitStat : Array, dunked : bool, targettedEnemy : bool) -> bool:
	# This is where all the biscuit logic will go
	
	var victim = enemy if targettedEnemy else player
	
	if not dunked:
		# Normal card played
		print("Damage:" + str(biscuitStat.get(3)) + " Defense: " + str(biscuitStat.get(4)))
		
		if player.has_state(2):
			victim.take_dryness(biscuitStat.get(3) * 2)
		elif player.has_state(3):
			victim.take_dryness(biscuitStat.get(3) / 2)
		else:
			victim.take_dryness(biscuitStat.get(3))
		if player.has_state(4) and not targettedEnemy:
			pass
		elif player.has_state(3):
			victim.add_defense(biscuitStat.get(4) * 2)
		else:
			victim.add_defense(biscuitStat.get(4))
		
		match biscuitStat.get(5):
			0:
				pass
			1:
				# Smore
				player.add_state_for_turns(1, 1, biscuitStat)
			2:
				# Make it bigger
				player.add_state_for_turns(2, 2, biscuitStat)
				player.remove_state(3)
			3:
				# Make it smaller
				player.add_state_for_turns(3, 2, biscuitStat)
				player.remove_state(2)
			4:
				# Untouchable
				player.add_state_for_turns(4, 2, biscuitStat)
	else:
		# Dunked card played
		print("Damage:" + str(biscuitStat.get(6)) + " Defense: " + str(biscuitStat.get(7)))
		if player.has_state(2):
			victim.take_dryness(biscuitStat.get(6) * 2)
		elif player.has_state(3):
			victim.take_dryness(biscuitStat.get(6) / 2)
		else:
			victim.take_dryness(biscuitStat.get(6))
		if player.has_state(4) and not targettedEnemy:
			pass
		elif player.has_state(3):
			victim.add_defense(biscuitStat.get(7) * 2)
		else:
			victim.add_defense(biscuitStat.get(7))
			
		match biscuitStat.get(8):
			0:
				pass
			1:
				# Smore
				player.add_state_for_turns(1, 1, biscuitStat)
			2:
				# Make it bigger
				player.add_state_for_turns(2, 2, biscuitStat)
				player.remove_state(3)
			3:
				# Make it smaller
				player.add_state_for_turns(3, 2, biscuitStat)
				player.remove_state(2)
			4:
				# Untouchable
				player.add_state_for_turns(4, 2, biscuitStat)
		
	if enemyTeacup.check_tea(): # Damages the enemy
		# If the enemy died
		win_fight()
		deckManager.hand.end_turn(false)
		return true
		
	if teacup.check_tea(): # Damages the player
		# If the player died
		lose_fight()
		deckManager.hand.end_turn(false)
		return true
	return false


func dunk_biscuit(biscuitStat : Array) -> bool: # Returns true if the biscuit sinks
	# This is where all the biscuit dunking logic will go
	
	match biscuitStat.get(9):
		0:
			var dunkChance = 0.5
			if randf() <= dunkChance:
				return true
		1: # Fire
			teacup.teaLevel = 50
			teacup.get_node("TeaMask/Tea").self_modulate=Color(1,0.2,0.15,1)
			return true
	return false

func _on_timer_timeout() -> void:
	if lostGame:
		GameManager.lose_battle()
	if wonGame:
		GameManager.end_battle()
	
	
	if actionProgress < len(enemyActions):
		play_enemy_action()
	elif actionProgress == len(enemyActions):
		actionProgress += 1
		enemy.reset()
		timer.wait_time = 0.5
		timer.start()
	else:
		actionProgress = 0
		end_enemy_turn()
