class_name Hand
extends Node2D

signal BiscuitPlayed(biscuit : Biscuit, targettedEnemy : bool)
signal BiscuitDunked(biscuit : Biscuit)
signal TurnEnded

@export var deckManager : DeckManager
@export var discardPile : DiscardPile
@export var drawPile : DrawPile
@export var dampStrength : float

var biscuitHand : Array[Biscuit] 
var biscuitStatHand : Array[Array]
var currentBiscuit : Biscuit
var draggingDisabled : bool
var resetAfterPlay : bool = true
var setHandPositions : bool = true

func init() -> void:
	biscuitHand = deckManager.handBiscuits

func draw_cards(numberOfCards : int) -> void:
	var leftOver : int = 0
	if len(drawPile.drawPile) < numberOfCards:
		# If you don't have enough cards inside the draw pile
		leftOver = numberOfCards - len(drawPile.drawPile) # Amount of cards you still need to draw
		for i in range(len(drawPile.drawPile)):
			# Draw the remaining cards in the draw pile
			biscuitStatHand.append(drawPile.drawPile.get(0))
			drawPile.drawPile.remove_at(0)
		
		discardPile.reshuffle() # Reshuffle the draw pile
		if len(drawPile.drawPile) < leftOver:
			# If there still aren't enough cards to draw
			leftOver = len(drawPile.drawPile)
		for i in range(leftOver):
			# Draw cards equal to the amount left over
			biscuitStatHand.append(drawPile.drawPile.get(0))
			drawPile.drawPile.remove_at(0)
	else:
		for i in range(numberOfCards):
			# Draw the amount of cards that you intended
			biscuitStatHand.append(drawPile.drawPile.get(0))
			drawPile.drawPile.remove_at(0)	
	for i in range(len(biscuitStatHand)):
		var displayBiscuit : Biscuit = biscuitHand.get(i)
		var biscuitStats : Array = biscuitStatHand.get(i)
		
		BiscuitHelper.set_biscuit_stats(displayBiscuit, biscuitStats)
	
	for biscuit in biscuitHand:
		biscuit.update_sprites()
	
	reset_display_biscuits_positions(len(biscuitStatHand), true)
	for i in len(biscuitStatHand):
		biscuitHand.get(i).modulate = Color(1, 1, 1, 1)

func reset_display_biscuits_positions(biscuitCount : int, updatePositions : bool) -> void:
	for i in range(len(biscuitHand)):
		var displayBiscuit : Biscuit = biscuitHand.get(i)
		if i < len(biscuitStatHand):
			if setHandPositions:
				displayBiscuit.handPosition = calculate_biscuit_display_positions(biscuitCount).get(i)
		else:
			if setHandPositions:
				displayBiscuit.handPosition = Vector2(0, 2000.0)
		if updatePositions and setHandPositions:
			displayBiscuit.position = displayBiscuit.handPosition

func calculate_biscuit_display_positions(biscuitCount : int) -> Array[Vector2]:
	var positions : Array[Vector2]
	
	for i in range(biscuitCount):
		positions.append(Vector2.ZERO)
	
	if biscuitCount % 2 == 0:
		# Even amount of cards

		var middle_index = biscuitCount / 2.0 - 0.5
		
		for i in range(0, int(middle_index + 0.5)):
			positions.set(int(middle_index - i - 0.5), Vector2(-200.0 * i - 100.0, 230.0))
			positions.set(int(middle_index + i + 0.5), Vector2(200.0 * i + 100.0, 230.0))
		
	else:
		# Odd amount of cards
		@warning_ignore("integer_division")
		var middle_index = biscuitCount / 2
		
		for i in range(middle_index + 1):
			positions.set(middle_index - i, Vector2(-200.0 * i, 230.0))
			positions.set(middle_index + i, Vector2(200.0 * i, 230.0))
	
	return positions

func discard_biscuit(biscuit : Biscuit, sunk : bool) -> void:
	var index : int = biscuitHand.find(biscuit)
	var biscuitStat : Array = biscuitStatHand.get(index)
	if not sunk:
		discardPile.discard(biscuitStat) # Discard the biscuit
	
	biscuitStatHand.erase(biscuitStat)
	biscuitHand.erase(biscuit)
	biscuitHand.append(biscuit)
	reset_display_biscuits_positions(len(biscuitStatHand), false)

	for i in range(len(biscuitStatHand)):
		var displayBiscuit : Biscuit = biscuitHand.get(i)
		displayBiscuit.modulate = Color(1, 1, 1, 1)
		if resetAfterPlay:
			displayBiscuit.reset()
	biscuit.position = Vector2(0.0, 2000.0)

func end_turn(biscuit : Biscuit, sunk : bool) -> void:
	var index : int = biscuitHand.find(biscuit)
	var biscuitStat : Array = biscuitStatHand.get(index)
	if sunk:
		biscuitStatHand.erase(biscuitStat)
	
	discardPile.discard_array(biscuitStatHand)
	biscuitStatHand.clear()
	for displayBiscuit in biscuitHand:
		displayBiscuit.resetting = false
		displayBiscuit.position = Vector2(0, 2000.0)
	
	for displayBiscuit in biscuitHand:
		displayBiscuit.isDunked = false
	
	TurnEnded.emit()
	
func reset_biscuit(biscuit : Biscuit) -> void:
	reset_display_biscuits_positions(len(biscuitStatHand), false)
	biscuit.modulate = Color(1, 1, 1, 1)
	biscuit.reset()

func set_biscuits() -> void:
	for i in range(len(biscuitStatHand)):
		var displayBiscuit : Biscuit = biscuitHand.get(i)
		var biscuitStats : Array = biscuitStatHand.get(i)
		
		BiscuitHelper.set_biscuit_stats(displayBiscuit, biscuitStats)

func _process(delta: float) -> void:
	
	for i in range(len(biscuitStatHand)):
		var biscuitStat = biscuitStatHand.get(i)
		var biscuit = biscuitHand.get(i)
		
		if biscuit.cardName != biscuitStat.get(0):
			# Try and fix mismatches
			print("Mismatch!")
			set_biscuits()
	
	if Input.is_action_just_pressed("Click"):
		# When dragging
		for biscuit in biscuitHand:
			if biscuit.hovered and not draggingDisabled:
				currentBiscuit = biscuit
				biscuit.z_index = 10
				biscuit.dragged = true
	elif Input.is_action_just_released("Click"):
		# When releasing
		if currentBiscuit:
			# If you are dragging a biscuit
			if deckManager.battleManager.teacup.hovering:
				# Dunked biscuit
				if currentBiscuit.isDunked:
					currentBiscuit.reset()
				else:
					currentBiscuit.isDunked = true
					currentBiscuit.modulate = Color(0, 0, 0, 0)
					BiscuitDunked.emit(currentBiscuit) # Dunks the biscuit
			elif deckManager.battleManager.player.hovering:
				# Dropped biscuit on hands
				if currentBiscuit.onDunkSpecial == 0:
					for displayBiscuit in biscuitHand:
						displayBiscuit.modulate = Color(0, 0, 0, 0)
					BiscuitPlayed.emit(currentBiscuit, false)
					# Plays the biscuit on the player
				else:
					currentBiscuit.reset()
			elif deckManager.battleManager.enemy.hovering:
				# Dropped biscuit on table
				if currentBiscuit.onDunkSpecial == 0:
					for displayBiscuit in biscuitHand:
						displayBiscuit.modulate = Color(0, 0, 0, 0)
					BiscuitPlayed.emit(currentBiscuit, true)
					# Plays the biscuit on the enemy
				else:
					currentBiscuit.reset()
			else:
				# Biscuit dropped
				currentBiscuit.reset()
				
			currentBiscuit.z_index = 9
			currentBiscuit.dragged = false
			currentBiscuit = null
	if currentBiscuit:
		currentBiscuit.position = lerp(currentBiscuit.position, get_global_mouse_position(), 1 - exp(-dampStrength * delta))
