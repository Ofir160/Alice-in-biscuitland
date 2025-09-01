class_name DiscardPile
extends Node

@export var drawPile : DrawPile

var discardPile : Array[int]

func reshuffle() -> void:
	drawPile.drawPile.append_array(discardPile)
	discardPile.clear()
	drawPile.shuffle()

func discard(biscuits : int) -> void:
	discardPile.append(biscuits)
	
func discard_array(biscuitStats : Array[int]) -> void:
	discardPile.append_array(biscuitStats)
