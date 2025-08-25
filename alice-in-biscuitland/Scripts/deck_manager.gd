class_name DeckManager
extends Node

var currentDeck : Array[Array]

# Each biscuit is represented as an array of values
# The order of the values determine what they are used for
# The order is: CardName Description Image Dryness Defense Special DunkedDryness DunkedDefense DunkedSpecial OnDunkSpecial

@export var teacup : Teacup
@export var player : Player
@export var currentEnemy : Enemy
@export var cardsToPlay : int
@export var drawPile : DrawPile
@export var hand : Hand
@export var initialDeck : Array[Biscuit]
@export var handBiscuits : Array[Biscuit]

func _ready() -> void:
	for biscuit in initialDeck:
		add_card(biscuit)
	drawPile.drawPile = currentDeck
	drawPile.shuffle()
	hand.draw_cards(5)

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
