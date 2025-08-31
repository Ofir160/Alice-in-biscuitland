extends Node


func get_biscuit_stats(biscuit : Biscuit) -> Array:
	var stats : Array
	stats.append(biscuit.cardName)
	stats.append(biscuit.Description)
	stats.append(biscuit.dunkedDescription)
	stats.append(biscuit.Img)
	stats.append(biscuit.dryness)
	stats.append(biscuit.defense)
	stats.append(biscuit.special)
	stats.append(biscuit.dunkedDryness)
	stats.append(biscuit.dunkedDefense)
	stats.append(biscuit.dunkedSpecial)
	stats.append(biscuit.onDunkSpecial)
	
	return stats
	

func set_biscuit_stats(biscuit : Biscuit, biscuitStats : Array) -> void:
	biscuit.cardName = biscuitStats.get(0)
	biscuit.Description = biscuitStats.get(1)
	biscuit.dunkedDescription = biscuitStats.get(2)
	biscuit.Img = biscuitStats.get(3)
	biscuit.dryness = biscuitStats.get(4)
	biscuit.defense = biscuitStats.get(5)
	biscuit.special = biscuitStats.get(6)
	biscuit.dunkedDryness = biscuitStats.get(7)
	biscuit.dunkedDefense = biscuitStats.get(8)
	biscuit.dunkedSpecial = biscuitStats.get(9)
	biscuit.onDunkSpecial = biscuitStats.get(10)
	biscuit.update_sprites()
