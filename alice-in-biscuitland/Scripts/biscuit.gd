class_name Biscuit
extends Node2D

const biscuitHover = preload("res://Assets/Audio/SFX/biscuitHover.ogg")
const biscuitUnhover = preload("res://Assets/Audio/SFX/biscuitUnhover.ogg")

@export var timeToReset : float
@export var hoverRight : bool
@export var hoverLeft : bool

@export var cardName:="";
@export var Description:="";
@export var dunkedDescription := ""
@export var Img:String="";
@export var dryness:=10;#basic stats
@export var defense:=5;
@export var special:=4;#id of the effect on eat
@export var dunkedDryness:=0;#stats after being dunked
@export var dunkedDefense:=0;
@export var dunkedSpecial:=0;#id of the effect on eat (AFTER DUNK)
@export var onDunkSpecial:=0;#id of the effect activated when dunked

@export var sfx : AudioStreamPlayer2D

var isDunked := false # has the card been dunked
var hovered := false
var dragged := false
var resetting := false
var handPosition : Vector2
var droppedPosition : Vector2
var elapsedTime : float

var effectiveDryness : int
var thirstPower : int
var effectiveDefense : int

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
	if isDunked:
		var text : String = dunkedDescription
		var thirstIndex : int = text.find("/a")
		
		if thirstIndex != -1:
			text = text.erase(thirstIndex, 2)
			text = text.insert(thirstIndex, str(effectiveDryness))
			
		var defenseIndex : int = text.find("/b")
		
		if defenseIndex != -1:
			text = text.erase(defenseIndex, 2)
			text = text.insert(defenseIndex, str(effectiveDefense))
			
		var jaffaIndex : int = text.find("/j")
		
		if jaffaIndex != -1:
			text = text.erase(jaffaIndex, 2)
			text = text.insert(jaffaIndex, str(thirstPower + 12))
			
		var gamblersIndex1 : int = text.find("/g")
		
		if gamblersIndex1 != -1:
			text = text.erase(gamblersIndex1, 2)
			text = text.insert(gamblersIndex1, str(thirstPower + 3))
			
		var gamblersIndex2 : int = text.find("/h")
		
		if gamblersIndex2 != -1:
			text = text.erase(gamblersIndex2, 2)
			text = text.insert(gamblersIndex2, str(thirstPower + 15))
			
		$description/text.text = text
	else:
		var text : String = Description
		var thirstIndex : int = text.find("/a")
		
		if thirstIndex != -1:
			text = text.erase(thirstIndex, 2)
			text = text.insert(thirstIndex, str(effectiveDryness))
			
		var defenseIndex : int = text.find("/b")
		
		if defenseIndex != -1:
			text = text.erase(defenseIndex, 2)
			text = text.insert(defenseIndex, str(effectiveDefense))
			
		var jaffaIndex : int = text.find("/j")
		
		if jaffaIndex != -1:
			text = text.erase(jaffaIndex, 2)
			text = text.insert(jaffaIndex, str(thirstPower + 18))
			
		var gamblersIndex1 : int = text.find("/g")
		
		if gamblersIndex1 != -1:
			text = text.erase(gamblersIndex1, 2)
			text = text.insert(gamblersIndex1, str(thirstPower + 3))
			
		var gamblersIndex2 : int = text.find("/h")
		
		if gamblersIndex2 != -1:
			text = text.erase(gamblersIndex2, 2)
			text = text.insert(gamblersIndex2, str(thirstPower + 15))
			
		$description/text.text = text
	$name/text.text = cardName
	$Sprite2D.texture = load(Img)

func _on_area_2d_mouse_entered() -> void:
	if not dragged:
		sfx.stream = biscuitHover
		sfx.play()
		if hoverRight:
			$AnimationPlayer.play("appear_right")
		elif hoverLeft:
			$AnimationPlayer.play("appear_left")
		else:
			$AnimationPlayer.play("appear")
	hovered = true;

func _on_area_2d_mouse_exited() -> void:
	if not dragged:
		sfx.stream = biscuitUnhover
		sfx.play()
		if hoverRight:
			$AnimationPlayer.play("vanish_left")
		elif hoverLeft:
			$AnimationPlayer.play("vanish_right")
		else:
			$AnimationPlayer.play("vanish")
	hovered = false
	
	
