class_name Alice
extends CharacterBody2D

@onready var camera: Camera2D = $Camera2D

@export var crossing=false
@export var cross_direction=0
@export var bTween=false
@onready var sprite: AnimatedSprite2D = $Sprite

var atEnemy : bool
var moving : bool

var speed= 500


func _ready() -> void:
	if GameManager.progress == 0:
		position = Vector2(-829, -1929)
	else:
		position = GameManager.alicePosition

func _process(delta: float) -> void:
	if bTween:
		if cross_direction==0:
			global_position=lerp(global_position,Vector2(12,-1160),0.15)
		elif cross_direction==1:
			global_position=lerp(global_position,Vector2(-470,-1000),0.15)
	if crossing or bTween:
		velocity=Vector2.ZERO
		sprite.play("Walking")
		return
	if atEnemy:
		velocity=Vector2.ZERO
		sprite.play("Idle")
	
	velocity.x=(Input.get_action_strength("ui_right")-Input.get_action_strength("ui_left"))
	velocity.y=(Input.get_action_strength("ui_down")-Input.get_action_strength("ui_up"))
	velocity=velocity.normalized()*speed
	
	if velocity.x >= 0.0:
		sprite.flip_h = false
	else:
		sprite.flip_h = true
	
	if abs(velocity.length()) <= 0.01:
		sprite.play("Idle")
	else:
		sprite.play("Walking")
	
func _physics_process(delta: float) -> void:
	if not crossing:
		move_and_slide()


func _on_bridge_entered(body: Node2D) -> void:
	if not crossing:
		get_parent().get_node("background/Bridge/TweenTimer").start(.3)
		cross_direction=0
		bTween=true
		sprite.flip_h = true
		
func _on_bridge2_entered(body: Node2D) -> void:
	if not crossing:
		get_parent().get_node("background/Bridge/TweenTimer").start(.3)
		cross_direction=1
		bTween=true
		sprite.flip_h = false

func _on_bridge_time() -> void:
	bTween=false
	if cross_direction==0:
		get_parent().get_node("background/Bridge").play("Cross")
	elif cross_direction==1:
		get_parent().get_node("background/Bridge").play_backwards("Cross")
