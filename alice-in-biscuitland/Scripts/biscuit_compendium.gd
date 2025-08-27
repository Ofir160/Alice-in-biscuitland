class_name BiscuitCompendium
extends Node

@export var biscuitCompendium : Array[Biscuit]
var biscuitStatCompendium : Array[Array]

func init() -> void:
	convert_biscuits_to_stats()

func convert_biscuits_to_stats() -> void:
	for biscuit in biscuitCompendium:
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
		
		biscuitStatCompendium.append(biscuitStat)

func get_3_biscuits() -> Array[Array]:
	var chosenBiscuits : Array[Array]
	biscuitStatCompendium.shuffle()
	
	chosenBiscuits.append(biscuitStatCompendium.get(0))
	chosenBiscuits.append(biscuitStatCompendium.get(1))
	chosenBiscuits.append(biscuitStatCompendium.get(2))
	
	return chosenBiscuits
