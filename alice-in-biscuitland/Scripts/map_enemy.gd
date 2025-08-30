extends Node2D

@export var index : int
@export var alice : Alice
@onready var button: TextureButton = $TextureButton

func _on_area_2d_body_entered(body: Node2D) -> void:
	if index == GameManager.progress:
		alice.atEnemy = true
		button.modulate = Color(1, 1, 1, 1)


func _on_texture_button_pressed() -> void:
	if alice.atEnemy:
		alice.atEnemy = false
		GameManager.start_battle()
