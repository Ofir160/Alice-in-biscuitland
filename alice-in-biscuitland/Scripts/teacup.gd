class_name Teacup
extends Node2D

var hovering : bool = false

func _on_area_2d_mouse_entered() -> void:
	hovering = true


func _on_area_2d_mouse_exited() -> void:
	hovering = false
