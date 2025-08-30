extends Node2D

@export var index : int
@export var alice : Alice

func _on_area_2d_body_entered(body: Node2D) -> void:
	if index == GameManager.progress:
		alice.atEnemy = true
