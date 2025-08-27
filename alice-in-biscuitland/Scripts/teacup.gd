class_name Teacup
extends Node2D

var maxTea : int
var teaLevel : int

var hovering : bool = false

func _on_area_2d_mouse_entered() -> void:
	hovering = true


func _on_area_2d_mouse_exited() -> void:
	hovering = false


func sip(amount : int) -> void:
	teaLevel -= amount
	
	
func check_tea() -> bool:
	if teaLevel <= 0:
		teaLevel = 0
		return true
	return false
	

func reset_tea() -> void:
	teaLevel = maxTea
	$TeaMask/Tea.position.y = (1-float(teaLevel) / maxTea) * 1000.0
	$TeaMask/Tea.self_modulate=Color(1, 1, 1, 1)
	$Text.text = str(teaLevel) + "/" + str(maxTea)

func _process(_delta: float) -> void:
	$TeaMask/Tea.position.y=lerp($TeaMask/Tea.position.y, (1-float(teaLevel) / maxTea) * 1000.0 ,0.1)
	$TeaMask/Tea.self_modulate=lerp($TeaMask/Tea.self_modulate,Color(1, 1, 1, 1),0.02)
	$Text.text = str(teaLevel) + "/" + str(maxTea)
