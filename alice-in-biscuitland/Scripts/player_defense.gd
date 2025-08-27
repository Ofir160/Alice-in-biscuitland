extends ProgressBar

@export var player : Player

func _process(delta: float) -> void:
	value = float(player.defense)
