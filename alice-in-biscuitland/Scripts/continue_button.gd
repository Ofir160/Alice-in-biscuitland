extends TextureButton

@onready var timer: Timer = $Timer

func _on_pressed() -> void:
	GameManager.chose_biscuit()
