extends ProgressBar

@export var enemy : Enemy

func _process(delta: float) -> void:
	value = float(enemy.defense)
