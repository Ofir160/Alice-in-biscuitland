class_name DeckManager
extends Node

@export var battleManager : BattleManager
@export var drawPile : DrawPile
@export var hand : Hand
@export var initialDeck : Array[Biscuit]
@export var handBiscuits : Array[Biscuit]

var cardsToPlay : int
var currentDeck : Array[Array]

# Each biscuit is represented as an array of values
# The order of the values determine what they are used for
# The order is: CardName Description Image Dryness Defense Special DunkedDryness DunkedDefense DunkedSpecial OnDunkSpecial

func _ready() -> void:
	for biscuit in initialDeck:
		add_card(biscuit)
	hand.BiscuitDunked.connect(on_biscuit_dunked)
	hand.BiscuitPlayed.connect(on_biscuit_played)


func on_biscuit_dunked(biscuitStat : Array) -> void:
	update_cards_to_play(battleManager.dunk_biscuit(biscuitStat))
	
	
func on_biscuit_played(biscuitStat : Array) -> void:
	battleManager.play_biscuit(biscuitStat, false)
	update_cards_to_play(false)
	

func update_cards_to_play(sunk : bool) -> void:
	cardsToPlay -= 1
	if sunk:
		hand.discard_biscuit(true)
		if cardsToPlay <= 0:
			hand.end_turn()
	else:
		if cardsToPlay <= 0:
			hand.end_turn()
		else:
			hand.discard_biscuit(false)
		

func add_card(biscuit : Biscuit) -> void:
	# Converts a biscuit into an array of its stats
	
	var biscuitStat := []
	biscuitStat.append(biscuit.cardName)
	biscuitStat.append(biscuit.Description)
	biscuitStat.append(biscuit.Img)
	biscuitStat.append(biscuit.dryness)
	biscuitStat.append(biscuit.defense)
	biscuitStat.append(biscuit.special)
	biscuitStat.append(biscuit.dunkedDryness)
	biscuitStat.append(biscuit.dunkedDefense)
	biscuitStat.append(biscuit.dunkedSpecial)
	biscuitStat.append(biscuit.onDunkSpecial)
	
	currentDeck.append(biscuitStat)
