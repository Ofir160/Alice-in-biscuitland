extends Node2D

@export var player : Player
@export var defenseBar : ProgressBar
@export var text : RichTextLabel

func _process(delta: float) -> void:
	defenseBar.value = float(player.defense)
	text.text = str(player.defense) + "/" + str(int(defenseBar.max_value))
