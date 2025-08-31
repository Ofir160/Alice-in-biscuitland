extends Node


func get_biscuit_stats(biscuit : Biscuit) -> Array:
	var stats : Array
	stats.append(biscuit.cardName)
	stats.append(biscuit.Description)
	stats.append(biscuit.dunkedDescription)
	stats.append(biscuit.Img)
	stats.append(biscuit.DunkedImg)
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
	biscuit.DunkedImg = biscuitStats.get(4)
	biscuit.dryness = biscuitStats.get(5)
	biscuit.defense = biscuitStats.get(6)
	biscuit.special = biscuitStats.get(7)
	biscuit.dunkedDryness = biscuitStats.get(8)
	biscuit.dunkedDefense = biscuitStats.get(9)
	biscuit.dunkedSpecial = biscuitStats.get(10)
	biscuit.onDunkSpecial = biscuitStats.get(11)
	biscuit.update_sprites()
