extends Node2D

const hover = preload("res://Assets/Audio/SFX/biscuitHover.ogg")
const unhover = preload("res://Assets/Audio/SFX/biscuitUnhover.ogg")

@export var enemy : Enemy
@onready var text: RichTextLabel = $RichTextLabel
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var description: RichTextLabel = $description/Description

@export var sfx : AudioStreamPlayer2D

func _process(delta: float) -> void:
	text.text = str(enemy.defensePower)
	description.text = "Increases Enemy Defense biscuits by " + str(enemy.defensePower)


func _on_area_2d_mouse_entered() -> void:
	sfx.stream = hover
	sfx.play()
	animation.play("appear")


func _on_area_2d_mouse_exited() -> void:
	sfx.stream = unhover
	sfx.play()
	animation.play("vanish")
