class_name DeckManager
extends Node

@export var battleManager : BattleManager
@export var drawPile : DrawPile
@export var hand : Hand
@export var discardPile : DiscardPile
@export var handBiscuits : Array[Biscuit]

var cardsToPlay : int

# Each biscuit is represented as an array of values
# The order of the values determine what they are used for
# The order is: CardName Description Image Dryness Defense Special DunkedDryness DunkedDefense DunkedSpecial OnDunkSpecial

func init() -> void:
	hand.BiscuitDunked.connect(on_biscuit_dunked)
	hand.BiscuitPlayed.connect(on_biscuit_played)
	hand.init()

func on_biscuit_dunked(biscuitStat : Array) -> void:
	# When you dunk a biscuit
	
	if battleManager.dunk_biscuit(biscuitStat):
		# If the biscuit sunk
		
		if len(drawPile.drawPile) == 0 and len(hand.biscuitStatHand) == 1 && len(discardPile.discardPile) == 0:
			# If you sank your last card
			battleManager.lose_fight() # Lose the fight
			hand.end_turn(true) # clean up
		else:
			cardsToPlay -= 1
			if cardsToPlay <= 0:
				hand.end_turn(true)
			else:
				hand.discard_biscuit(true)
	else:
		# If the biscuit didn't sink
		
		hand.reset_biscuit() # Doesn't play the biscuit
	
	
func on_biscuit_played(biscuitStat : Array, dunked : bool, targetedEnemy : bool) -> void:
	# When you play a biscuit
	
	if battleManager.play_biscuit(biscuitStat, dunked, targetedEnemy):
		# If the game is over because of that biscuit
		return
	else:
		# Otherwise count that as a card played
		update_cards_to_play()
	

func update_cards_to_play() -> void:
	# Checks whether to end the turn or to discard the biscuit
	
	cardsToPlay -= 1
	if cardsToPlay <= 0 || len(hand.biscuitStatHand) == 1:
		# If you have played 3 cards or if you played the last card in your hand
		hand.end_turn(false)
	else:
		hand.discard_biscuit(false)
		
