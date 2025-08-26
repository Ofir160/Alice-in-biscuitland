class_name Teacup
extends Node2D

var teaLevel : int

var hovering : bool = false

func _on_area_2d_mouse_entered() -> void:
	hovering = true


func _on_area_2d_mouse_exited() -> void:
	hovering = false

func sip(amount : int) -> bool:
	teaLevel -= amount
	if teaLevel <= 0:
		teaLevel = 0
		return true
	return false

func _process(_delta: float) -> void:
	$Tea.scale.y=lerp($Tea.scale.y,teaLevel/100.0,0.1)
	$Tea.position.y=lerp($Tea.position.y,100.0-teaLevel,0.1)
	$Tea.self_modulate=lerp($Tea.self_modulate,Color(.2,0.1,0.03,1),0.02)
