class_name Player
extends Node2D

var hovering : bool

func _on_area_2d_mouse_entered() -> void:
	hovering = true


func _on_area_2d_mouse_exited() -> void:
	hovering = false
