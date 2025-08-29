class_name Player
extends Node2D

@export var teacup : Teacup
@export var displayBiscuits : Array[Biscuit]
@onready var timer: Timer = $"Player State Biscuits/Timer"
@onready var timer2: Timer = $"Player State Biscuits/Timer2"

var defense : int
var attackPower : int
var defensePower : int


var hovering : bool
var states : Array[int] # Array of all the states the player is in
var turnTimers : Dictionary[int, int]
var addTimers : Dictionary[int, Array]

var state1OnScreen : bool = false
var state2OnScreen : bool = false
var state3OnScreen : bool = false

func take_dryness(dryness : int) -> void:
	var thirst : int
	if dryness <= defense:
		defense = defense - dryness
	else:
		thirst = dryness - defense
		defense = 0
	teacup.sip(thirst)


func add_defense(_defense : int) -> void:
	defense += _defense
	
func add_state(state : int, biscuitStat : Array, inTurns : int) -> void:
	if inTurns == 0:
		if len(states) == 0:
			var displayBiscuit = displayBiscuits.get(0)
			set_biscuit(displayBiscuit, biscuitStat)
			
			print("Added state 1")
			
			$"Player State Biscuits/AnimationPlayer".play("Fly In 1")
			state1OnScreen = true
		if len(states) == 1:
			var displayBiscuit = displayBiscuits.get(1)
			set_biscuit(displayBiscuit, biscuitStat)
			
			print("Added state 2")
			$"Player State Biscuits/AnimationPlayer2".play("Fly In 2")
			state2OnScreen = true
		if len(states) == 2:
			var displayBiscuit = displayBiscuits.get(2)
			set_biscuit(displayBiscuit, biscuitStat)
			
			print("Added state 3")
			$"Player State Biscuits/AnimationPlayer3".play("Fly In 3")
			state3OnScreen = true
		if len(states) >= 3:
			print("Too many states added!")
			return
		states.append(state)
	else:
		var data : Array
		data.append(inTurns)
		data.append(biscuitStat)
		addTimers.set(state, data)
	
func set_biscuit(displayBiscuit : Biscuit, biscuitStats : Array) -> void:
	displayBiscuit.cardName = biscuitStats.get(0)
	displayBiscuit.Description = biscuitStats.get(1)
	displayBiscuit.Img = biscuitStats.get(2)
	displayBiscuit.modulate = Color(1, 1, 1, 1)
	displayBiscuit.update_sprites()
	
func copy_biscuit(biscuit1 : Biscuit, biscuit2 : Biscuit) -> void:
	# Moves biscuit1 to biscuit2
	
	var biscuit1position = biscuit1.position
	
	biscuit1.cardName = biscuit2.cardName
	biscuit1.Description = biscuit2.Description
	biscuit1.Img = biscuit2.Img
	biscuit1.modulate = Color(1, 1, 1, 1)
	biscuit2.modulate = Color(0, 0, 0, 0)
	
	biscuit1.position = biscuit2.position
	biscuit2.position = biscuit1position
	biscuit1.update_sprites()
	
func add_state_for_turns(state : int, biscuitStat : Array, turns : int) -> void:
	if not has_state(state):
		add_state(state, biscuitStat, 0)
	if turnTimers.has(state):
		print("Already had state")
		turnTimers.set(state, turnTimers.get(state) + turns)
	else:
		print("Added state: " + str(state) + "for turns: " + str(turns))
		turnTimers.set(state, turns)
	
func step_timers():
	for key in turnTimers.keys():
		var newTime = turnTimers.get(key) - 1
		if newTime <= 0:
			print("Removed a state because it's timer ran out")
			remove_state(key)
			turnTimers.erase(key)
		else:
			turnTimers.set(key, newTime)
	for key in addTimers.keys():
		var newTime = addTimers.get(key).get(0) - 1
		if newTime <= 0:
			print("Added a new state because it's add timer ran out")
			add_state_for_turns(key, addTimers.get(key).get(1), 1)
			addTimers.erase(key)
		else:
			var newData : Array
			newData.append(newTime)
			newData.append(addTimers.get(key).get(1))
			addTimers.set(key, newData)
	
func remove_state(state : int) -> void:
	if has_state(state):
		var index = states.find(state)
		states.remove_at(index)
		if index == 0:
			print("Removed state 1")
			$"Player State Biscuits/AnimationPlayer".play("Fly Out 1")
			state1OnScreen = false
		if index == 1:
			print("Removed state 2")
			$"Player State Biscuits/AnimationPlayer2".play("Fly Out 2")
			state2OnScreen = false
		if index == 2:
			print("Removed state 3")
			$"Player State Biscuits/AnimationPlayer3".play("Fly Out 3")
			state3OnScreen = false
		if turnTimers.find_key(state):
			turnTimers.erase(state)
		timer.wait_time = 1.0
		timer.start()


func has_state(state : int) -> bool:
	if states.find(state) != -1:
		return true
	else:
		return false

func _on_area_2d_mouse_entered() -> void:
	hovering = true


func _on_area_2d_mouse_exited() -> void:
	hovering = false


func _on_timer_timeout() -> void:
	if not state1OnScreen:
		if not state2OnScreen:
			if state3OnScreen:
				# Move 3 to 1
				copy_biscuit(displayBiscuits.get(0), displayBiscuits.get(2))
				print("Swapped state 3 with state 1")
				$"Player State Biscuits/AnimationPlayer3".play("Fly Up 3 - 1")
				state3OnScreen = false
				state1OnScreen = true
		else:
			if state3OnScreen:
				# Move 2 to 1 and 3 to 2
				print("Swapped state 2 with state 1")
				print("Swapped state 3 with state 2")
				copy_biscuit(displayBiscuits.get(0), displayBiscuits.get(1))
				$"Player State Biscuits/AnimationPlayer2".play("Fly Up 2 - 1")
				copy_biscuit(displayBiscuits.get(1), displayBiscuits.get(2))
				$"Player State Biscuits/AnimationPlayer3".play("Fly Up 3 - 2")
				state3OnScreen = false
				state1OnScreen = true
				state2OnScreen = true
			else:
				# Move 2 to 1
				print("Swapped state 2 with state 1")
				copy_biscuit(displayBiscuits.get(0), displayBiscuits.get(1))
				$"Player State Biscuits/AnimationPlayer2".play("Fly Up 2 - 1")
				state2OnScreen = false
				state1OnScreen = true
	else:
		# State 1 on Screen
		if not state2OnScreen:
			# State 2 off screen
			if state3OnScreen:
				# Move 3 to 2
				print("Swapped state 3 with state 2")
				copy_biscuit(displayBiscuits.get(1), displayBiscuits.get(2))
				$"Player State Biscuits/AnimationPlayer3".play("Fly Up 3 - 2")
				state3OnScreen = false
				state2OnScreen = true
