extends Node2D

@export var player : Player
@onready var text: RichTextLabel = $RichTextLabel

func _process(delta: float) -> void:
	text.text = str(player.attackPower)
