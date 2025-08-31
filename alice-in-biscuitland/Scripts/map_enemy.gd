class_name MapEnemy
extends Node2D

@export var index : int
@export var alice : Alice
@export var button : TextureButton

func _on_area_2d_body_entered(body: Node2D) -> void:
	if index == GameManager.enemyProgress:
		alice.atEnemy = true
		button.disabled = false
		button.modulate = Color(1, 1, 1, 1)


func on_battle_button_pressed() -> void:
	if alice.atEnemy:
		alice.atEnemy = false
		GameManager.alicePosition = alice.position
		GameManager.start_battle()
