class_name Player
extends Node2D

@export var teacup : Teacup
@export var displayBiscuits : Array[Biscuit]
@onready var timer: Timer = $"Player State Biscuits/Timer"
@onready var timer2: Timer = $"Player State Biscuits/Timer2"

var defense : int
var hovering : bool
var states : Array[int] # Array of all the states the player is in
var turnTimers : Dictionary[int, int]

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
	
	
func add_state(state : int, biscuitStat : Array) -> void:
	if len(states) == 0:
		var displayBiscuit = displayBiscuits.get(0)
		set_biscuit(displayBiscuit, biscuitStat)
		
		$"Player State Biscuits/AnimationPlayer".play("Fly In 1")
		state1OnScreen = true
	if len(states) == 1:
		var displayBiscuit = displayBiscuits.get(1)
		set_biscuit(displayBiscuit, biscuitStat)
		
		$"Player State Biscuits/AnimationPlayer2".play("Fly In 2")
		state2OnScreen = true
	if len(states) == 2:
		var displayBiscuit = displayBiscuits.get(2)
		set_biscuit(displayBiscuit, biscuitStat)
		
		$"Player State Biscuits/AnimationPlayer3".play("Fly In 3")
		state3OnScreen = true
	if len(states) >= 3:
		return
	states.append(state)
	
	
func set_biscuit(displayBiscuit : Biscuit, biscuitStats : Array) -> void:
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
	
func copy_biscuit(biscuit1 : Biscuit, biscuit2 : Biscuit) -> void:
	var biscuit1position = biscuit1.position
	
	biscuit1.cardName = biscuit2.cardName
	biscuit1.Description = biscuit2.Description
	biscuit1.Img = biscuit2.Img
	biscuit1.dryness = biscuit2.dryness
	biscuit1.defense = biscuit2.defense
	biscuit1.special = biscuit2.special
	biscuit1.dunkedDryness = biscuit2.dunkedDryness
	biscuit1.dunkedDefense = biscuit2.dunkedDefense
	biscuit1.dunkedSpecial = biscuit2.dunkedSpecial
	biscuit1.onDunkSpecial = biscuit2.onDunkSpecial
	
	biscuit1.position = biscuit2.position
	biscuit2.position = biscuit1position
	biscuit1.update_sprites()
	
	
func add_state_for_turns(state : int, turns : int, biscuitStat : Array) -> void:
	if not has_state(state):
		add_state(state, biscuitStat)
	if turnTimers.has(state):
		turnTimers.set(state, turnTimers.get(state) + turns)
	else:
		turnTimers.set(state, turns)
	
func step_timers():
	for key in turnTimers.keys():
		var newTime = turnTimers.get(key) - 1
		if newTime <= 0:
			remove_state(key)
			turnTimers.erase(key)
		else:
			turnTimers.set(key, newTime)
	
func remove_state(state : int) -> void:
	if has_state(state):
		var index = states.find(state)
		states.remove_at(index)
		if index == 0:
			$"Player State Biscuits/AnimationPlayer".play("Fly Out 1")
			state1OnScreen = false
		if index == 1:
			$"Player State Biscuits/AnimationPlayer2".play("Fly Out 2")
			state2OnScreen = false
		if index == 2:
			$"Player State Biscuits/AnimationPlayer3".play("Fly Out 3")
			state3OnScreen = false
		if turnTimers.find_key(state):
			timer.wait_time = 1.0
			timer.start()
			turnTimers.erase(state)


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
				$"Player State Biscuits/AnimationPlayer3".play("Fly Up 3 - 1")
		else:
			if state3OnScreen:
				# Move 2 to 1 and 3 to 2
				copy_biscuit(displayBiscuits.get(0), displayBiscuits.get(1))
				$"Player State Biscuits/AnimationPlayer2".play("Fly Up 2 - 1")
				copy_biscuit(displayBiscuits.get(1), displayBiscuits.get(2))
				$"Player State Biscuits/AnimationPlayer3".play("Fly Up 3 - 2")
			else:
				copy_biscuit(displayBiscuits.get(0), displayBiscuits.get(1))
				$"Player State Biscuits/AnimationPlayer2".play("Fly Up 2 - 1")
	else:
		if not state2OnScreen:
			if state3OnScreen:
				# Move 3 to 2
				copy_biscuit(displayBiscuits.get(1), displayBiscuits.get(2))
