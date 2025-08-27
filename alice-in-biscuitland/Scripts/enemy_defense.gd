extends Node2D

@export var enemy : Enemy
@export var defenseBar : ProgressBar
@export var text : RichTextLabel

func _process(delta: float) -> void:
	defenseBar.value = float(enemy.defense)
	text.text = str(enemy.defense) + "/" + str(int(defenseBar.max_value))
