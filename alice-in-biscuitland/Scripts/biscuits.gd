extends Node

const achievement = preload("res://Assets/Audio/SFX/achievement.wav")

@export var biscuits : Array[Biscuit]
@export var sfx : AudioStreamPlayer2D

var chosenBiscuit : Biscuit
var cardsTaken : int 

func _ready() -> void:
	
	var chosenBiscuits = GameManager.get_3_random_biscuits()
	
	for i in range(len(chosenBiscuits)):
		print(i)
		var displayBiscuit = biscuits.get(i)
		var chosenBiscuit = chosenBiscuits.get(i)
		
		GameManager.set_biscuit(displayBiscuit, chosenBiscuit)
		displayBiscuit.update_sprites()
		

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Click"):
		# When dragging
		for biscuit in biscuits:
			if biscuit.hovered:
				chosenBiscuit = biscuit
		if chosenBiscuit:
			GameManager.add_biscuit(chosenBiscuit)
			
			sfx.stream = achievement
			sfx.play()
			
			chosenBiscuit.modulate = Color(0, 0, 0, 0)
			chosenBiscuit.position = Vector2(0, 2000)
			chosenBiscuit = null
			cardsTaken += 1
			if cardsTaken == 2:
				for biscuit in biscuits:
					biscuit.modulate = Color(0, 0, 0, 0)
					biscuit.position = Vector2(0, 2000)
