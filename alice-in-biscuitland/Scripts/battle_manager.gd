class_name BattleManager
extends Node

@onready var timer: Timer = $Timer
@onready var deckManager: DeckManager = $"Deck Manager"

@export var cardsToPlay : int
@export var teacup : Teacup
@export var player : Player
@export var enemy : Enemy

func _ready() -> void:
	start_fight()

func start_fight() -> void:
	enemy.index = 0 # Sets what enemy we are fighting
	deckManager.drawPile.drawPile = deckManager.currentDeck
	deckManager.drawPile.shuffle()
	deckManager.hand.TurnEnded.connect(end_player_turn)
	teacup.teaLevel = 100
	player.thirst = 0
	player.defense = 0
	enemy.teaLevel = 100
	enemy.thirst = 0
	enemy.defense = 0
	start_player_turn()


func start_player_turn() -> void:
	# Start the players turn
	player.defense = 0
	enemy.thirst = 0
	deckManager.hand.draw_cards(5)
	deckManager.cardsToPlay = cardsToPlay
	enemy.set_action()


func end_player_turn() -> void:
	enemy.defense = 0
	start_enemy_turn()


func start_enemy_turn() -> void:
	# Start the enemies turn
	timer.start()
	var action : Array = enemy.get_action()
	
	player.take_dryness(action.get(0))
	enemy.add_defense(action.get(1))
	
func end_enemy_turn() -> void:
	if teacup.sip(player.thirst):
		lose_fight()
	else:
		player.thirst = 0
		start_player_turn()
	

func lose_fight() -> void:
	deckManager.hand.TurnEnded.disconnect(end_player_turn)
	print("You looose")


func win_fight() -> void:
	deckManager.hand.TurnEnded.disconnect(end_player_turn)
	print("You wiiiiin")

func play_biscuit(biscuitStat : Array, dunked : bool, targettedEnemy : bool) -> bool:
	# This is where all the biscuit logic will go
	
	var victim = enemy if targettedEnemy else player
	
	if not dunked:
		print("Normal card played")
		victim.take_dryness(biscuitStat.get(3))
		victim.add_defense(biscuitStat.get(4))
	else:
		print("Dunked card played")
		victim.take_dryness(biscuitStat.get(6))
		victim.add_defense(biscuitStat.get(7))
		
	if enemy.sip(enemy.thirst): # Damages the enemy
		# If the enemy died
		win_fight()
		deckManager.hand.end_turn(false)
		return true
	else:
		enemy.thirst = 0
		
	if teacup.sip(player.thirst): # Damages the player
		# If the player died
		lose_fight()
		deckManager.hand.end_turn(false)
		return true
	else:
		player.thirst = 0
	return false


func dunk_biscuit(biscuitStat : Array) -> bool: # Returns true if the biscuit sinks
	# This is where all the biscuit dunking logic will go
	
	match biscuitStat.get(9):
		0:
			var dunkChance = 0.5
			if randf() <= dunkChance:
				return true
		1:
			teacup.teaLevel = 100
			teacup.get_node("Tea").self_modulate=Color(1,0.2,0.15,1)
			return true
	return false

func _on_timer_timeout() -> void:
	end_enemy_turn()
