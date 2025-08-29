class_name DeckManager
extends Node

@export var battleManager : BattleManager
@export var drawPile : DrawPile
@export var hand : Hand
@export var discardPile : DiscardPile
@export var handBiscuits : Array[Biscuit]
@export var animationBiscuit : Sprite2D
@export var dunkAnimation : AnimationPlayer
@onready var timer: Timer = $Timer

var cardsToPlay : int
var biscuitSunk : bool
var currentBiscuit : Biscuit

# Each biscuit is represented as an array of values
# The order of the values determine what they are used for
# The order is: CardName Description Image Dryness Defense Special DunkedDryness DunkedDefense DunkedSpecial OnDunkSpecial

func init() -> void:
	hand.BiscuitDunked.connect(on_biscuit_dunked)
	hand.BiscuitPlayed.connect(on_biscuit_played)
	hand.init()

func on_biscuit_dunked(biscuit : Biscuit) -> void:
	# When you dunk a biscuit
	
	if battleManager.dunk_biscuit(biscuit):
		# If the biscuit sunk
		biscuitSunk = true
		currentBiscuit = biscuit
		currentBiscuit.modulate = Color(0, 0, 0, 0)
		
		animationBiscuit.texture = load(currentBiscuit.Img)
		
		dunkAnimation.play("Sink")

		timer.start()
	else:
		# If the biscuit didn't sink
		biscuitSunk = false
		currentBiscuit = biscuit
		currentBiscuit.modulate = Color(0, 0, 0, 0)
		currentBiscuit.position = Vector2(-645, 220)
		
		animationBiscuit.texture = load(currentBiscuit.Img)
		
		dunkAnimation.play("Dunk")

		timer.start()


func on_biscuit_played(biscuit : Biscuit, targetedEnemy : bool) -> void:
	# When you play a biscuit
	
	if battleManager.play_biscuit(biscuit, targetedEnemy):
		# If the game is over because of that biscuit
		return
	else:
		# Otherwise count that as a card played
		update_cards_to_play(biscuit)
	

func update_cards_to_play(biscuit : Biscuit) -> void:
	# Checks whether to end the turn or to discard the biscuit
	cardsToPlay -= 1
	if cardsToPlay <= 0 || len(hand.biscuitStatHand) == 1:
		# If you have played 3 cards or if you played the last card in your hand
		hand.end_turn(biscuit, false)
	else:
		hand.discard_biscuit(biscuit, false)
		


func _on_timer_timeout() -> void:
	if biscuitSunk:
		if currentBiscuit.onDunkSpecial == 4:
			# Fireproof
			cardsToPlay -= 1
			if cardsToPlay <= 0:
				hand.end_turn(currentBiscuit, false)
			else:
				hand.discard_biscuit(currentBiscuit, false)
		else:
			if len(drawPile.drawPile) == 0 and len(hand.biscuitStatHand) == 1 && len(discardPile.discardPile) == 0:
				# If you sank your last card
				battleManager.lose_fight() # Lose the fight
				hand.end_turn(currentBiscuit, true) # clean up
			else:
				cardsToPlay -= 1
				if cardsToPlay <= 0:
					hand.end_turn(currentBiscuit, true)
				else:
					hand.discard_biscuit(currentBiscuit, true)
	else:
		hand.reset_biscuit(currentBiscuit) # Doesn't play the biscuit
