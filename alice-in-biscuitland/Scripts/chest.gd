class_name Chest
extends Area2D

const openSprite = preload("res://Assets/Sprites/Chests/Chest Open.png")

@export var alice : Alice
@export var index : int
var hovering : bool

func _ready() -> void:
	if GameManager.chestProgress.find(index) != -1:
		$Sprite2D.texture = openSprite

func _on_mouse_entered() -> void:
	hovering = true

func _on_mouse_exited() -> void:
	hovering = false
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Click") and hovering:
		if GameManager.chestProgress.find(index) == -1:
			GameManager.alicePosition = alice.position
			GameManager.chestProgress.append(index)
			GameManager.found_chest()
