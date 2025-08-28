extends CharacterBody2D

@onready var camera: Camera2D = $Camera2D

@export var crossing=false
@export var cross_direction=0
@export var bTween=false

var speed= 500


func _ready() -> void:
	match GameManager.progress:
		0:
			# White Rabbit / Just spawned in
			position = Vector2(-1011, -2035)
		1:
			# Killed the white rabbit
			position = Vector2(-13, -1921)
		2:
			# Killed the mad hatter
			position = Vector2(-938, -540)
		3:
			# Killed cheshire cat
			position = Vector2(1218, -567)
		4:
			# Killed jabberwocky
			position = Vector2(-1216, 1664)

func _process(delta: float) -> void:
	if bTween:
		if cross_direction==0:
			global_position=lerp(global_position,Vector2(12,-1044),0.15)
		elif cross_direction==1:
			global_position=lerp(global_position,Vector2(-470,-843),0.15)
	if crossing or bTween:
		velocity=Vector2.ZERO
		return
	
	velocity.x=(Input.get_action_strength("ui_right")-Input.get_action_strength("ui_left"))
	velocity.y=(Input.get_action_strength("ui_down")-Input.get_action_strength("ui_up"))
	velocity=velocity.normalized()*speed
func _physics_process(delta: float) -> void:
	if not crossing:
		move_and_slide()


func _on_bridge_entered(body: Node2D) -> void:
	if not crossing:
		get_parent().get_node("background/Bridge/TweenTimer").start(.3)
		cross_direction=0
		bTween=true
func _on_bridge2_entered(body: Node2D) -> void:
	if not crossing:
		get_parent().get_node("background/Bridge/TweenTimer").start(.3)
		cross_direction=1
		bTween=true


func _on_bridge_time() -> void:
	bTween=false
	if cross_direction==0:	
		get_parent().get_node("background/Bridge").play("Cross")
		get_parent().get_node("background/Bridge").seek(0.5)
		global_position=Vector2(12,-1044)
	elif cross_direction==1:
		
		get_parent().get_node("background/Bridge").seek(1.5)
		get_parent().get_node("background/Bridge").play_backwards("Cross")
		global_position=Vector2(-470,-843)
