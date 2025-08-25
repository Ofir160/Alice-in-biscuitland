class_name Teacup
extends Node2D

var teaLevel=100.0

var hovering : bool = false

func _on_area_2d_mouse_entered() -> void:
	hovering = true


func _on_area_2d_mouse_exited() -> void:
	hovering = false

func sip(amount:int) -> void:
	teaLevel-=amount
	if teaLevel<=0:
		teaLevel=0
		print("You LOSE!!!")
		#LOSE CODE

func _process(delta: float) -> void:
	$Tea.scale.y=lerp($Tea.scale.y,teaLevel/100,0.1)
	$Tea.position.y=lerp($Tea.position.y,100-teaLevel,0.1)
	$Tea.self_modulate=lerp($Tea.self_modulate,Color(.2,0.1,0.03,1),0.02)
