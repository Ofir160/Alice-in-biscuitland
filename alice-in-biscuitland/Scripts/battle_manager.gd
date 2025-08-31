class_name BattleManager
extends Node

const defense = preload("res://Assets/Audio/SFX/defense boop.mp3")

@onready var timer: Timer = $Timer
@onready var sacrifice_timer: Timer = $SacrificeTimer
@onready var deckManager: DeckManager = $"Deck Manager"
@onready var enemyTurnStartTimer: Timer = $"Enemy Turn Start Timer"
@onready var defenseSound: AudioStreamPlayer2D = $"Defense Sound"
@onready var thirstSound: AudioStreamPlayer2D = $"Thirst Sound"
@onready var slurpSound: AudioStreamPlayer2D = $"Slurp Sound"

@export var cardsToPlay : int
@export var teacup : Teacup
@export var enemyTeacup : Teacup
@export var player : Player
@export var enemy : Enemy
@export var turnSwitcher : AnimationPlayer

var enemyActions : Array[Array]
var actionProgress : int

var sacrificeIterations : int
var startingSacrificeIterations : int
var sacrificeTarget : int = 0
var sacrificeBiscuit : Biscuit

var frostValue : int

var lostGame : bool
var wonGame : bool

func _ready() -> void:
	deckManager.init()
	start_fight()

func start_fight() -> void:
	enemy.index = GameManager.enemyProgress # Sets what enemy we are fighting
	enemy.init()
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
	
	player.step_timers()
	player.defense = 0
	deckManager.hand.draw_cards(5)
	
	if player.has_state(6):
		var amount = randi_range(1, 5)
		var biscuit : Biscuit = player.displayBiscuits.get(player.states.find(6))
		biscuit.Description = "Must play " + str(amount) + " Biscuits this turn"
		biscuit.update_sprites()
		
		deckManager.cardsToPlay = amount
	elif player.has_state(1):
		deckManager.cardsToPlay = 5
	else:
		deckManager.cardsToPlay = cardsToPlay
		
	if enemy.index == 0 and enemy.specialState:
		enemy.attackPower += 1
		
	enemy.set_action()
	enemy.set_dialogue()

func end_player_turn() -> void:
	enemy.defense = 0
	enemyActions = []
	start_enemy_turn()

func start_enemy_turn() -> void:
	# Start the enemies turn
	
	turnSwitcher.play("Enemy Turn")
	enemyTurnStartTimer.start()
			
func deal_enemy_thirst(amount : int) -> void:
	thirstSound.play()
	if player.has_state(2):
		player.take_dryness(amount * 2)
	else:
		player.take_dryness(amount)
			
func add_enemy_defense(amount : int) -> void:
	defenseSound.play()
	enemy.add_defense(amount)
					
func play_enemy_action() -> void:
	
	var action : Array = enemyActions.get(actionProgress)
	
	if action.get(0) > 0:
		deal_enemy_thirst(action.get(0) + enemy.attackPower)
		
	if action.get(1) > 0:
		enemy.add_defense(action.get(1) + enemy.defensePower)
	
	match action.get(2):
		0:
			pass
		1:
			enemy.specialState = true
		2:
			enemy.attackPower += 1
		3:
			enemy.defensePower += 1
		4:
			deal_enemy_thirst(randi_range(3, 10) + enemy.attackPower)
		5:
			add_enemy_defense(randi_range(3, 10) + enemy.defensePower)
		6:
			enemy.attackPower += randi_range(0, 3)
		7:
			enemy.defensePower += randi_range(0, 3)
		8:
			var stats : Array = [action.get(5), action.get(6), action.get(7)]
			player.add_state(6, stats, 1)
		9:
			player.attackPower -= 1
			player.defensePower -= 1
		10:
			var stats : Array = ["Does Nothing", "Does Nothing", "Still Does Nothing", "res://Assets/Sprites/Biscuits/Untitled_Artwork-37.png", "res://Assets/Sprites/Biscuits/Untitled_Artwork-38.png", 0, 0, 0, 0, 0, 0, 0]
			deckManager.hand.discardPile.discard(stats)
		11:
			var stats : Array = [action.get(5), action.get(6), action.get(7)]
			player.add_state(7, stats, 0)
			teacup.dunkChance = 1.0
			teacup.get_node("Thermometer").play("Fully Fire")
			teacup.get_node("FireAnimation").play("Fully Fire")
		12:
			enemy.attackPower += 3
		13:
			player.defensePower -= 1
		14:
			enemy.attackPower += 5
			enemy.specialState = true
		15:
			enemy.enemyTeacup.teaLevel += 10
		16:
			enemy.redQueenGuardCount += 1
			enemy.redQueenGuardCount = clampi(enemy.redQueenGuardCount, 0, 3)
			
			if enemy.redQueenGuardCount == 1:
				enemy.guards.play("1 Guards")
			elif enemy.redQueenGuardCount == 2:
				enemy.guards.play("2 Guards")
			elif enemy.redQueenGuardCount == 3:
				enemy.guards.play("3 Guards")
		17:
			deal_enemy_thirst((3 + enemy.attackPower) * enemy.redQueenGuardCount)
			
	
	if teacup.check_tea():
		GameManager.deathMessage = "You drank all your Tea!"
		lose_fight()
	actionProgress += 1
	
	if actionProgress < len(enemyActions):
		timer.wait_time = 2
		timer.start()
	else:
		timer.wait_time = 2 # 0.8 is the time till the last card goes. So this must be bigger than 0.8
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
	enemy.on_die()
	
func finish_fight() -> void:
	timer.wait_time = 1.5
	timer.start()
	wonGame = true

func add_defence(amount : int, victim : Variant, targettedEnemy : bool) -> void:
	if amount > 0:
		if player.has_state(4) and not targettedEnemy:
			pass
		elif player.has_state(3):
			defenseSound.play()
			victim.add_defense(amount * 2)
		elif player.has_state(11) and victim == player:
			defenseSound.play()
			victim.add_defense(amount * 2)
		else:
			defenseSound.play()
			victim.add_defense(amount)

func deal_dryness(amount : int, victim : Variant, targettedEnemy : bool) -> void:
	if amount > 0:
		if victim == enemy and enemy.index == 2 and enemy.specialState:
			enemy.descriptionAnimation.play("vanish")
			enemy.specialState = false
		else:
			thirstSound.play()
			if victim == enemy and enemy.index == 3 and enemy.specialState:
				enemy.attackPower += 1
			if player.has_state(2):
				victim.take_dryness(amount * 2)
			elif player.has_state(3):
				victim.take_dryness(amount / 2)
			elif player.has_state(10) and victim == enemy:
				victim.take_dyness(amount * 2)
			else:
				victim.take_dryness(amount)

func play_biscuit(biscuit : Biscuit, targettedEnemy : bool) -> bool:
	# This is where all the biscuit logic will go
	
	var victim = enemy if targettedEnemy else player
	var biscuitStat = BiscuitHelper.get_biscuit_stats(biscuit)
	
	if not biscuit.isDunked:
		# Normal card played
		if biscuit.dryness != 0:
			deal_dryness(biscuit.dryness + player.attackPower, victim, targettedEnemy)
		if biscuit.defense != 0:
			add_defence(biscuit.defense + player.defensePower, victim, targettedEnemy)
		
		match biscuit.special:
			0:
				pass
			1:
				# Smore
				var stats = biscuitStat.duplicate()
				stats.set(1, "Must Play All Biscuits")
				player.add_state(1, stats, 1)
			2:
				# Make it bigger
				player.add_state_for_turns(10, biscuitStat, 2)
				player.remove_state(3)
			3:
				# Make it smaller
				player.add_state_for_turns(11, biscuitStat, 2)
				player.remove_state(2)
			4:
				# Untouchable
				var stats = biscuitStat.duplicate()
				stats.set(1, "Cannot Gain Defence")
				player.add_state(4, stats, 1)
			5:
				# Jaffa Cake
				var chance = 0.5
				if randf() >= chance:
					deal_dryness(12 + player.attackPower, victim, targettedEnemy)
				else:
					pass
			6:
				# Gambler's Cookie
				var dryness = randi_range(3, 10)
				deal_dryness(dryness + player.attackPower, victim, targettedEnemy)
				var defence = randi_range(3, 10)
				add_defence(defence + player.defensePower, victim, targettedEnemy)
			7:
				# Sacrifice
				deckManager.cardsToPlay = len(deckManager.hand.biscuitStatHand)
				
				deal_dryness((deckManager.cardsToPlay - 1) * (7 + player.attackPower), victim, targettedEnemy)
				
				var chance : float = teacup.dunkChance
				deckManager.hand.draggingDisabled = true
				deckManager.hand.resetAfterPlay = false
				deckManager.hand.setHandPositions = false
				teacup.dunkChance = 1.0
				teacup.get_node("Thermometer").play("Fully Fire")
				teacup.get_node("FireAnimation").play("Fully Fire")
				sacrificeIterations = (len(deckManager.hand.biscuitStatHand) - 1) * 2 - 1
				startingSacrificeIterations = sacrificeIterations
				sacrificeTarget = 0
				sacrificeBiscuit = biscuit
				
				var firstBiscuit : Biscuit = deckManager.hand.biscuitHand.get(0)
				if firstBiscuit != sacrificeBiscuit:
					firstBiscuit.handPosition = Vector2(-640, 390)
					firstBiscuit.reset()
				else:
					var nextBiscuit : Biscuit = deckManager.hand.biscuitHand.get(1)
					nextBiscuit.handPosition = Vector2(-640, 390)
					nextBiscuit.reset()
				
				sacrifice_timer.wait_time = 1.0
				sacrifice_timer.start()
			8:
				# Ragebait
				if enemy.attacking():
					teacup.dunkChance = 0.75
					teacup.get_node("Thermometer").play("Fire")
					teacup.get_node("FireAnimation").play("Fire")
					teacup.set_tea_state(1)
			9:
				# Frost
				var stats = biscuitStat.duplicate()
				stats.set(1, "Prevents the next biscuit from sinking in tea")
				teacup.get_node("Thermometer").play("Fully Frozen")
				teacup.get_node("FireAnimation").play("Natural")
				teacup.dunkChance = 0.0
				player.add_state(5, stats, 0)
			10:
				# Renewal
				teacup.dunkChance = 0.5
				teacup.get_node("Thermometer").play("Natural")
				teacup.get_node("FireAnimation").play("Natural")
				teacup.add_tea(5)
				slurpSound.play()
				teacup.set_tea_state(0)
			11:
				# Line of Defense
				
				var defenseCards : int = 0
				for currentStat in deckManager.hand.biscuitStatHand:
					if currentStat.get(5) != 0:
						defenseCards += 1
				add_defence(5 + 2 * defenseCards + player.defensePower, victim, targettedEnemy)
			12:
				# Grow
				
				player.attackPower += 1
				player.defensePower += 1

	else:
		# Dunked card played
		if biscuit.dunkedDryness != 0:
			deal_dryness(biscuit.dunkedDryness + player.attackPower, victim, targettedEnemy)
		if biscuit.dunkedDefense != 0:
			add_defence(biscuit.dunkedDefense + player.defensePower, victim, targettedEnemy)
			
		match biscuit.dunkedSpecial:
			0:
				pass
			1:
				# Smore
				var stats = biscuitStat.duplicate()
				stats.set(1, "Must Play All Biscuits")
				player.add_state(1, stats, 1)
				player.attackPower += 1
			2:
				# Make it bigger
				player.add_state_for_turns(10, biscuitStat, 2)
				player.remove_state(11)
			3:
				# Make it smaller
				player.add_state_for_turns(11, biscuitStat, 2)
				player.remove_state(10)
			4:
				# Untouchable
				var stats = biscuitStat.duplicate()
				stats.set(1, "Cannot Gain Defence")
				player.add_state(4, stats, 1)
			5:
				# Jaffa cake
				var chance = 0.5
				if randf() >= chance:
					deal_dryness(18 + player.attackPower, victim, targettedEnemy)
				else:
					pass
			6:
				# Gambler's Cookie
				var dryness = randi_range(3, 15)
				deal_dryness(dryness + player.attackPower, victim, targettedEnemy)
				var defence = randi_range(3, 15)
				add_defence(defence + player.defensePower, victim, targettedEnemy)
			7:
				# Sacrifice
				deckManager.cardsToPlay = len(deckManager.hand.biscuitStatHand)
				
				deal_dryness((deckManager.cardsToPlay - 1) * (10 + player.attackPower), victim, targettedEnemy)
				
				var chance : float = teacup.dunkChance
				deckManager.hand.draggingDisabled = true
				deckManager.hand.resetAfterPlay = false
				deckManager.hand.setHandPositions = false
				teacup.dunkChance = 1.0
				teacup.get_node("Thermometer").play("Fully Fire")
				teacup.get_node("FireAnimation").play("Fully Fire")
				sacrificeIterations = len(deckManager.hand.biscuitStatHand) - 1
				startingSacrificeIterations = sacrificeIterations
				sacrificeTarget = 0
				sacrificeBiscuit = biscuit
				
				var firstBiscuit : Biscuit = deckManager.hand.biscuitHand.get(sacrificeTarget)
				if firstBiscuit != sacrificeBiscuit:
					firstBiscuit.handPosition = Vector2(-640, 390)
					firstBiscuit.reset()
				else:
					sacrificeTarget += 1
					var nextBiscuit : Biscuit = deckManager.hand.biscuitHand.get(sacrificeTarget)
					nextBiscuit.handPosition = Vector2(-640, 390)
					nextBiscuit.reset()
				
				sacrifice_timer.wait_time = 1.0
				sacrifice_timer.start()
			8:
				# Ragebait
				if enemy.attacking():
					teacup.dunkChance = 0.75
					teacup.get_node("Thermometer").play("Fire")
					teacup.get_node("FireAnimation").play("Fully Fire")
					teacup.set_tea_state(1)
			9:
				# Frost
				var stats = biscuitStat.duplicate()
				stats.set(1, "Prevents the next defense card from sinking in tea")
				teacup.get_node("Thermometer").play("Fully Frozen")
				teacup.get_node("FireAnimation").play("Natural")
				teacup.dunkChance = 0.0
				frostValue = 2
				player.add_state(8, stats, 0)
			10:
				# Renewal
				teacup.dunkChance = 0.5
				teacup.get_node("Thermometer").play("Natural")
				teacup.get_node("FireAnimation").play("Natural")
				teacup.add_tea(5)
				slurpSound.play()
				teacup.set_tea_state(0)
			11:
				# Line of Defense
				
				var defenseCards : int = 0
				for currentStat in deckManager.hand.biscuitStatHand:
					if currentStat.get(5) != 0:
						defenseCards += 1
				add_defence(5 + 4 * defenseCards + player.defensePower, victim, targettedEnemy)
			12:
				# Grow
				
				player.attackPower += 2
				player.defensePower += 2
				
		
	if enemyTeacup.check_tea(): # Damages the enemy
		# If the enemy died
		win_fight()
		deckManager.hand.end_turn(biscuit, false)
		return true
		
	if teacup.check_tea(): # Damages the player
		# If the player died
		GameManager.deathMessage = "You drank all your Tea!"
		lose_fight()
		deckManager.hand.end_turn(biscuit, false)
		return true
		
	enemy.on_play_biscuit()
	
	return false

func dunk_biscuit(biscuit : Biscuit) -> bool: # Returns true if the biscuit sinks
	# This is where all the biscuit dunking logic will go
	
	var result : bool = false
	
	match biscuit.onDunkSpecial:
		0:
			if randf() <= teacup.dunkChance:
				if teacup.check_tea_state(1):
					if biscuit.defense != 0:
						player.attackPower += 3
				result = true
		1:
			# Refill
			teacup.add_tea(10)
			slurpSound.play()
			teacup.get_node("TeaMask/Tea").self_modulate=Color(1,0.2,0.15,1)
			teacup.get_node("FireAnimation").play("Natural")
			teacup.set_tea_state(0)
			result = true
		2: 
			# Fire
			teacup.set_tea_state(1)
			teacup.get_node("Thermometer").play("Fire")
			teacup.get_node("FireAnimation").play("Fire")
			teacup.dunkChance = 0.75
			result = true
		3:
			# Ice
			teacup.set_tea_state(2)
			teacup.get_node("Thermometer").play("Frozen")
			teacup.get_node("FireAnimation").play("Natural")
			teacup.dunkChance = 0.25
			result = true
		4:
			# Fireproof
			if randf() <= teacup.dunkChance:
				if teacup.check_tea_state(1):
					if biscuit.defense != 0:
						player.attackPower += 1
				result = true
				
	if player.has_state(5):
		if teacup.check_tea_state(1):
			teacup.get_node("Thermometer").play("Fire")
			teacup.get_node("FireAnimation").play("Fire")
			teacup.dunkChance = 0.75
		elif teacup.check_tea_state(2):
			teacup.get_node("Thermometer").play("Frozen")
			teacup.get_node("FireAnimation").play("Natural")
			teacup.dunkChance = 0.25
		else:
			teacup.get_node("Thermometer").play("Natural")
			teacup.get_node("FireAnimation").play("Natural")
			teacup.dunkChance = 0.5
		player.remove_state(5)
	if player.has_state(7):
		if teacup.check_tea_state(1):
			teacup.get_node("Thermometer").play("Fire")
			teacup.get_node("FireAnimation").play("Fire")
			teacup.dunkChance = 0.75
		elif teacup.check_tea_state(2):
			teacup.get_node("Thermometer").play("Frozen")
			teacup.get_node("FireAnimation").play("Natural")
			teacup.dunkChance = 0.25
		else:
			teacup.get_node("Thermometer").play("Natural")
			teacup.get_node("FireAnimation").play("Natural")
			teacup.dunkChance = 0.5
		player.remove_state(7)
	if player.has_state(8):
		frostValue -= 1
		if frostValue == 0:
			if teacup.check_tea_state(1):
				teacup.get_node("Thermometer").play("Fire")
				teacup.get_node("FireAnimation").play("Fire")
				teacup.dunkChance = 0.75
			elif teacup.check_tea_state(2):
				teacup.get_node("Thermometer").play("Frozen")
				teacup.get_node("FireAnimation").play("Natural")
				teacup.dunkChance = 0.25
			else:
				teacup.get_node("Thermometer").play("Natural")
				teacup.get_node("FireAnimation").play("Natural")
				teacup.dunkChance = 0.5
			player.remove_state(8)
				
	if biscuit.defense != 0 and teacup.check_tea_state(2):
		player.defensePower += 3
	return result

func _on_timer_timeout() -> void:
	if lostGame:
		GameManager.lose_battle()
	if wonGame:
		GameManager.end_battle()
	
	
	if actionProgress < len(enemyActions):
		play_enemy_action()
		
		var index = randi_range(0, 1)
		
		match index:
			0:
				deckManager.sfx.stream = deckManager.biscuitEat1
				deckManager.sfx.play()
			1:
				deckManager.sfx.stream = deckManager.biscuitEat2
				deckManager.sfx.play()
		
	elif actionProgress == len(enemyActions):
		actionProgress += 1
		enemy.reset()
		timer.wait_time = 2
		turnSwitcher.play("Player Turn")
		timer.start()
	else:
		actionProgress = 0
		end_enemy_turn()

func _on_sacrifice_timer_timeout() -> void:
	if sacrificeIterations > 0:
		if sacrificeIterations % 2 == 1:
			var currentBiscuit : Biscuit = deckManager.hand.biscuitHand.get(0)
			if currentBiscuit != sacrificeBiscuit:
				deckManager.on_biscuit_dunked(currentBiscuit)
			else:
				var nextCurrentBiscuit : Biscuit = deckManager.hand.biscuitHand.get(0)
				deckManager.on_biscuit_dunked(nextCurrentBiscuit)
			sacrifice_timer.wait_time = 2
			sacrifice_timer.start()
			sacrificeIterations -= 1
		else:
			if sacrificeIterations > 1:
				var resetBiscuit : Biscuit = deckManager.hand.biscuitHand.get(0)
				if resetBiscuit != sacrificeBiscuit:
					resetBiscuit.handPosition = Vector2(-640, 390)
					resetBiscuit.reset()
				else:
					var nextResetBiscuit : Biscuit = deckManager.hand.biscuitHand.get(0) 
					nextResetBiscuit.handPosition = Vector2(-640, 390)
					nextResetBiscuit.reset()
				sacrifice_timer.wait_time = 1
				sacrifice_timer.start()
				sacrificeIterations -= 1
	else:
		deckManager.hand.draggingDisabled = false
		deckManager.hand.resetAfterPlay = true
		deckManager.hand.setHandPositions = true
		if player.has_state(5):
			teacup.dunkChance = 1
			teacup.get_node("Thermometer").play("Fully Frozen")
			teacup.get_node("FireAnimation").play("Natural")
		elif teacup.check_tea_state(1):
			teacup.dunkChance = 0.75
			teacup.get_node("Thermometer").play("Fire")
			teacup.get_node("FireAnimation").play("Fire")
		elif teacup.check_tea_state(2):
			teacup.dunkChance = 0.25
			teacup.get_node("Thermometer").play("Fully Fire")
			teacup.get_node("FireAnimation").play("Fully Fire")
		else:
			teacup.dunkChance = 0.5
			teacup.get_node("Thermometer").play("Natural")
			teacup.get_node("FireAnimation").play("Natural")

func _on_enemy_turn_start_timer_timeout() -> void:
	enemyActions = enemy.get_actions() # Starts the animations
	
	timer.wait_time = 3
	timer.start()

func _process(delta: float) -> void:
	for biscuit in deckManager.hand.biscuitHand:
		if not biscuit.isDunked:
			biscuit.effectiveDryness = biscuit.dryness + player.attackPower
			biscuit.thirstPower = player.attackPower
			if player.has_state(2) or player.has_state(10):
				biscuit.effectiveDryness *= 2
			elif player.has_state(3):
				biscuit.effectiveDryness /= 2
			biscuit.effectiveDefense = biscuit.defense + player.defensePower
			if player.has_state(4):
				biscuit.effectiveDefense = 0
			elif player.has_state(3) or player.has_state(11):
				biscuit.effectiveDefense *= 2 
		else:
			biscuit.effectiveDryness = biscuit.dunkedDryness + player.attackPower
			biscuit.thirstPower = player.attackPower
			if player.has_state(2) or player.has_state(10):
				biscuit.effectiveDryness *= 2
			elif player.has_state(3):
				biscuit.effectiveDryness /= 2
			biscuit.effectiveDefense = biscuit.dunkedDefense + player.defensePower
			if player.has_state(4):
				biscuit.effectiveDefense = 0
			elif player.has_state(3) or player.has_state(11):
				biscuit.effectiveDefense *= 2 
		biscuit.update_sprites()
	for enemyBiscuit in enemy.biscuits:
		if player.has_state(2):
			enemyBiscuit.effectiveDryness = (enemyBiscuit.dryness + enemy.attackPower) * 2
		else:
			enemyBiscuit.effectiveDryness = enemyBiscuit.dryness + enemy.attackPower
			
		if player.has_state(3) or player.has_state(11):
			enemyBiscuit.effectiveDefense = (enemyBiscuit.defense + enemy.defensePower) / 2
		else:
			enemyBiscuit.effectiveDefense = (enemyBiscuit.defense + enemy.defensePower)
		enemyBiscuit.update_sprites()
