class_name Hand
extends Node2D

@export var deckManager : DeckManager
@export var discardPile : DiscardPile
@export var drawPile : DrawPile
@export var dampStrength : float

var biscuitHand : Array[Biscuit] 
var biscuitStatHand : Array[Array]
var teacup : Teacup
var player : Player
var enemy : Enemy
var currentBiscuit : Biscuit

func _ready() -> void:
	teacup = deckManager.teacup
	player = deckManager.player
	enemy = deckManager.currentEnemy
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
		
		displayBiscuit.cardName = biscuitStats.get(0)
		displayBiscuit.Description = biscuitStats.get(1)
		displayBiscuit.Img = biscuitStats.get(2)
		displayBiscuit.dryness = biscuitStats.get(3)
		displayBiscuit.defense = biscuitStats.get(4)
		displayBiscuit.special = biscuitStats.get(5)
		displayBiscuit.dunkedDryness = biscuitStats.get(6)
		displayBiscuit.dunkedDefense = biscuitStats.get(7)
		displayBiscuit.dunkedSpecial = biscuitStats.get(8)
		displayBiscuit.onDunkSpecial = biscuitStats.get(9)
		displayBiscuit.update_sprites()
	reset_display_biscuits_positions(len(biscuitStatHand), true)

func reset_display_biscuits_positions(biscuitCount : int, updatePositions : bool) -> void:
	for i in range(len(biscuitHand)):
		var displayBiscuit : Biscuit = biscuitHand.get(i)
		if i < len(biscuitStatHand):
			displayBiscuit.handPosition = calculate_biscuit_display_positions(biscuitCount).get(i)
		else:
			displayBiscuit.handPosition = Vector2(0, 2000.0)
		if updatePositions:
			displayBiscuit.position = displayBiscuit.handPosition

func calculate_biscuit_display_positions(biscuitCount : int) -> Array[Vector2]:
	var positions : Array[Vector2]
	
	for i in range(biscuitCount):
		positions.append(Vector2.ZERO)
	
	if biscuitCount % 2 == 0:
		# Even amount of cards

		var middle_index = biscuitCount / 2.0 - 0.5
		
		for i in range(0, int(middle_index + 0.5)):
			positions.set(int(middle_index - i - 0.5), Vector2(-300.0 * i - 150.0, 450.0))
			positions.set(int(middle_index + i + 0.5), Vector2(300.0 * i + 150.0, 450.0))
		
	else:
		# Odd amount of cards
		@warning_ignore("integer_division")
		var middle_index = biscuitCount / 2
		
		for i in range(middle_index + 1):
			positions.set(middle_index - i, Vector2(-300.0 * i, 450.0))
			positions.set(middle_index + i, Vector2(300.0 * i, 450.0))
	
	return positions

func play_biscuit(biscuit : Biscuit) -> void:
	
	deckManager.cardsToPlay -= 1
	if deckManager.cardsToPlay <= 0:
		# End turn
		discardPile.discard_array(biscuitStatHand)
		biscuitStatHand.clear()
		reset_display_biscuits_positions(0, true)
		return
	
	var biscuitStat : Array = biscuitStatHand.get(biscuitHand.find(biscuit))
	discardPile.discard(biscuitStat)
	
	reset_display_biscuits_positions(len(biscuitStatHand), true)
	biscuitStatHand.erase(biscuitStat)
	biscuitHand.erase(biscuit)
	biscuitHand.append(biscuit)
	reset_display_biscuits_positions(len(biscuitStatHand), false)
	
	for i in range(len(biscuitStatHand)):
		var displayBiscuit : Biscuit = biscuitHand.get(i)
		displayBiscuit.reset()
	
	currentBiscuit.position = Vector2(0.0, 2000.0)
	

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Click"):
		# When dragging
		for biscuit in biscuitHand:
			if biscuit.hovered:
				currentBiscuit = biscuit
				biscuit.z_index = 10
				biscuit.dragged = true
	elif Input.is_action_just_released("Click"):
		# When releasing
		if currentBiscuit:
			# If you are dragging a biscuit
			if teacup.hovering:
				# Dunked biscuit
				currentBiscuit.isDunked = true
			elif player.hovering:
				# Ate biscuit
				play_biscuit(currentBiscuit)
			elif enemy.hovering:
				# Enemy ate biscuit
				play_biscuit(currentBiscuit)
			else:
				# Biscuit dropped
				currentBiscuit.reset()
				
			currentBiscuit.z_index = 0
			currentBiscuit.dragged = false
			currentBiscuit = null
	if currentBiscuit:
		currentBiscuit.position = lerp(currentBiscuit.position, get_global_mouse_position(), 1 - exp(-dampStrength * delta))
