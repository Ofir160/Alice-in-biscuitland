extends Sprite2D

@export var index : int
@export var biscuitIndex : int
var hovering : bool

func _ready() -> void:
	if GameManager.biscuitProgress.find(index) != -1:
		modulate = Color(0, 0, 0, 0)
		$Area2D/CollisionShape2D.disabled = true
		
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Click") and hovering:
		if GameManager.biscuitProgress.find(index) == -1:
			GameManager.biscuitProgress.append(index)
			GameManager.add_biscuit(biscuitIndex)
			modulate = Color(0, 0, 0, 0)
			$Area2D/CollisionShape2D.disabled = true

func _on_area_2d_mouse_entered() -> void:
	hovering = true

func _on_area_2d_mouse_exited() -> void:
	hovering = false
