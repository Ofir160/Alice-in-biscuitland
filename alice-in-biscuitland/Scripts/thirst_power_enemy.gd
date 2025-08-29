extends Node2D

@export var enemy : Enemy
@onready var text: RichTextLabel = $RichTextLabel
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var description: RichTextLabel = $description/Description


func _process(delta: float) -> void:
	text.text = str(enemy.attackPower)
	description.text = "Increases Enemy Thirst biscuits by " + str(enemy.attackPower)


func _on_area_2d_mouse_entered() -> void:
	animation.play("appear")


func _on_area_2d_mouse_exited() -> void:
	animation.play("vanish")
