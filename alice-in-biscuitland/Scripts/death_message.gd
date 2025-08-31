extends MeshInstance2D

func _ready() -> void:
	$text.text = GameManager.deathMessage
