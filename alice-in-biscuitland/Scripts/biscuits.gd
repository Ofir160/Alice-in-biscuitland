extends Node

@export var biscuits : Array[Biscuit]
@export var biscuitCompendium : BiscuitCompendium

var chosenBiscuit : Biscuit

func _ready() -> void:
	biscuitCompendium.init()
	
	var biscuitStats = biscuitCompendium.get_3_biscuits()
	
	for i in range(len(biscuitStats)):
		var biscuitStat = biscuitStats.get(i)
		var displayBiscuit = biscuits.get(i)
		
		displayBiscuit.cardName = biscuitStat.get(0)
		displayBiscuit.Description = biscuitStat.get(1)
		displayBiscuit.Img = biscuitStat.get(2)
		displayBiscuit.dryness = biscuitStat.get(3)
		displayBiscuit.defense = biscuitStat.get(4)
		displayBiscuit.special = biscuitStat.get(5)
		displayBiscuit.dunkedDryness = biscuitStat.get(6)
		displayBiscuit.dunkedDefense = biscuitStat.get(7)
		displayBiscuit.dunkedSpecial = biscuitStat.get(8)
		displayBiscuit.onDunkSpecial = biscuitStat.get(9)
		displayBiscuit.update_sprites()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Click"):
		# When dragging
		for biscuit in biscuits:
			if biscuit.hovered:
				chosenBiscuit = biscuit
		if chosenBiscuit:
			GameManager.add_biscuit(chosenBiscuit)
			for biscuit in biscuits:
				biscuit.modulate = Color(0, 0, 0, 0)
				biscuit.position = Vector2(0, 2000)
