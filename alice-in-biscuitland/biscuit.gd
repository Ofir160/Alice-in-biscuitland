extends Node2D

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

var isDunked=false#has the card been dunked

func _ready():
	$description/text.text=Description
	$name/text.text=cardName
	$Sprite2D.texture=load(Img)


func _on_area_2d_mouse_entered() -> void:
	$AnimationPlayer.play("appear")


func _on_area_2d_mouse_exited() -> void:
	$AnimationPlayer.play("vanish")
