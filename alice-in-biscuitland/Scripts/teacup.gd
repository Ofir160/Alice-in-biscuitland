class_name Teacup
extends Node2D

@export var playerTeacup : bool

var maxTea : int
var teaLevel : int
var dunkChance : float = 0.5

var hovering : bool = false
var teacup_state : int # 0 if normal. 1 if fire. 2 if Ice. 3 If we have time :p

func _on_area_2d_mouse_entered() -> void:
	if teacup_state != 0 and playerTeacup:
		$AnimationPlayer.play("appear")
	hovering = true


func _on_area_2d_mouse_exited() -> void:
	if teacup_state != 0 and playerTeacup:
		$AnimationPlayer.play("vanish")
	hovering = false


func sip(amount : int) -> void:
	teaLevel -= amount
	
	
func add_tea(amount : int) -> void:
	teaLevel += amount
	teaLevel = clampi(teaLevel, 0, maxTea)
	
func check_tea() -> bool:
	if teaLevel <= 0:
		teaLevel = 0
		return true
	return false


func check_tea_state(state : int) -> bool:
	return state == teacup_state


func set_tea_state(state : int) -> void:
	teacup_state = state
	match state:
		0:
			pass
		1:
			$description/text.text = "Whenever you sink a defense card into tea increase attack power. Increases sinking chance"
		2:
			$description/text.text = "Dunking defense cards into tea increases defense power. Decreases sinking chance"


func reset_tea() -> void:
	teaLevel = maxTea
	$TeaMask/Tea.position.y = (1-float(teaLevel) / maxTea) * 1000.0
	$TeaMask/Tea.self_modulate=Color(1, 1, 1, 1)
	$Text.text = str(teaLevel) + "/" + str(maxTea)


func _process(_delta: float) -> void:
	$TeaMask/Tea.position.y=lerp($TeaMask/Tea.position.y, (1-float(teaLevel) / maxTea) * 1000.0 ,0.1)
	$TeaMask/Tea.self_modulate=lerp($TeaMask/Tea.self_modulate,Color(1, 1, 1, 1),0.02)
	$Text.text = str(teaLevel) + "/" + str(maxTea)
