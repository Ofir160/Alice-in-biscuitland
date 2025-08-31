extends TextureButton

@export var enemy : MapEnemy

func _ready() -> void:
	modulate = Color(0, 0, 0, 0)

func _on_pressed() -> void:
	enemy.on_battle_button_pressed()
