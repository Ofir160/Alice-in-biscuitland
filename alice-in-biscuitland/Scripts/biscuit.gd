class_name Biscuit
extends Node2D

@export var timeToReset : float
@export var hoverRight : bool

@export var cardName:="";
@export var Description:="";
@export var Img:String="";
@export var dryness:=10;#basic stats
@export var defense:=5;
@export var special:=4;#id of the effect on eat
@export var dunkedDryness:=0;#stats after being dunked
@export var dunkedDefense:=0;
@export var dunkedSpecial:=0;#id of the effect on eat (AFTER DUNK)
@export var onDunkSpecial:=0;#id of the effect activated when dunked

var isDunked := false # has the card been dunked
var hovered := false
var dragged := false
var resetting := false
var handPosition : Vector2
var droppedPosition : Vector2
var elapsedTime : float

func _process(delta: float) -> void:
	if resetting:
		elapsedTime += delta
		var t : float = elapsedTime / timeToReset
		position = lerp(droppedPosition, handPosition, 1 - (1 - t) * (1 - t))
		
		if t >= 1.0:
			resetting = false
			modulate = Color(1, 1, 1, 1)


func reset() -> void:
	resetting = true
	elapsedTime = 0
	droppedPosition = position

func update_sprites():
	$description/text.text = Description
	$name/text.text = cardName
	$Sprite2D.texture = load(Img)


func _on_area_2d_mouse_entered() -> void:
	if not dragged:
		if not hoverRight:
			$AnimationPlayer.play("appear")
		else:
			$AnimationPlayer.play("appear_right")
	hovered = true;


func _on_area_2d_mouse_exited() -> void:
	if not dragged:
		if not hoverRight:
			$AnimationPlayer.play("vanish")
		else:
			$AnimationPlayer.play("vanish_left")
	hovered = false
	
	
