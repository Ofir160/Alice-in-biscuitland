extends StaticBody2D

@export var progressNeeded : int
@onready var collisionShape: CollisionShape2D = $CollisionShape2D

func _process(delta: float) -> void:
	if GameManager.progress >= progressNeeded:
		collisionShape.disabled = true
