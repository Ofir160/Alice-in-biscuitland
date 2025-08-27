extends Node2D

@export var index : int


func _on_area_2d_body_entered(body: Node2D) -> void:
	if index == GameManager.progress:
		GameManager.start_battle()
