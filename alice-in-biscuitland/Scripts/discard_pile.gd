class_name DiscardPile
extends Node

@export var drawPile : DrawPile

var discardPile : Array[Array]

func reshuffle() -> void:
	drawPile.drawPile.append_array(discardPile)
	discardPile.clear()
	drawPile.shuffle()

func discard(biscuitStat : Array) -> void:
	discardPile.append(biscuitStat)
	
func discard_array(biscuitStats : Array[Array]) -> void:
	discardPile.append_array(biscuitStats)
