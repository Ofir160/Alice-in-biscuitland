class_name TurnManager
extends Node

@onready var timer: Timer = $Timer
@onready var deckManager: DeckManager = $"Deck Manager"

@export var cardsToPlay : int

func _ready() -> void:
	start_fight()

func start_fight() -> void:
	deckManager.drawPile.drawPile = deckManager.currentDeck
	deckManager.drawPile.shuffle()
	deckManager.hand.TurnEnded.connect(end_player_turn)
	start_player_turn()


func start_player_turn() -> void:
	# Start the players turn
	deckManager.hand.draw_cards(5)
	deckManager.cardsToPlay = cardsToPlay


func end_player_turn() -> void:
	start_enemy_turn()


func start_enemy_turn() -> void:
	# Start the enemies turn
	timer.start()
	
	
func end_enemy_turn() -> void:
	start_player_turn()
	

func end_fight() -> void:
	pass


func _on_timer_timeout() -> void:
	end_enemy_turn()
