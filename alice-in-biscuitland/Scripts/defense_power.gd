extends Node2D

@export var player : Player
@onready var text: RichTextLabel = $RichTextLabel
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var description: RichTextLabel = $description/Description


func _process(delta: float) -> void:
	text.text = str(player.defensePower)
	if player.defensePower < 0:
		description.text = "Decreases Defense biscuits by " + str(-player.defensePower)
	else:
		description.text = "Increases Defense biscuits by " + str(player.defensePower)


func _on_area_2d_mouse_entered() -> void:
	animation.play("appear")


func _on_area_2d_mouse_exited() -> void:
	animation.play("vanish")
