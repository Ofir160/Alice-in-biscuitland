class_name Biscuit
extends Node2D

const biscuitHover = preload("res://Assets/Audio/SFX/biscuitHover.ogg")
const biscuitUnhover = preload("res://Assets/Audio/SFX/biscuitUnhover.ogg")

@export var timeToReset : float
@export var hoverRight : bool
@export var hoverLeft : bool

@export var cardName : String
@export var description : String
@export var dunkedDescription : String
@export var img : String
@export var dunkedImg : String 
@export var thirst : int
@export var defense : int
@export var dunkedThirst : int
@export var dunkedDefense : int
@export var index : int
@export var dunkable : bool
@export var enemyPlayable : bool
@export var playerPlayable : bool

@export var sfx : AudioStreamPlayer2D

var isDunked : bool
var hovered : bool
var dragged : bool
var lerping : bool
var desiredPosition : Vector2
var startingPosition : Vector2
var elapsedTime : float

var effectiveThirst : int
var thirstPower : int
var effectiveDefense : int

func _process(delta: float) -> void:
	if lerping:
		elapsedTime += delta
		var t : float = elapsedTime / timeToReset
		position = lerp(startingPosition, desiredPosition, 1 - (1 - t) * (1 - t))
		
		if t >= 1.0:
			lerping = false
			modulate = Color(1, 1, 1, 1)
			
func reset() -> void:
	lerping = true
	elapsedTime = 0
	startingPosition = position

func update_sprites():
	if isDunked:
		var text : String = dunkedDescription
		var thirstIndex : int = text.find("/a")
		
		if thirstIndex != -1:
			text = text.erase(thirstIndex, 2)
			text = text.insert(thirstIndex, str(effectiveThirst))
			
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
		$Sprite2D.texture = load(dunkedImg)
	else:
		var text : String = description
		var thirstIndex : int = text.find("/a")
		
		if thirstIndex != -1:
			text = text.erase(thirstIndex, 2)
			text = text.insert(thirstIndex, str(effectiveThirst))
			
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
		$Sprite2D.texture = load(img)
	$name/text.text = cardName

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
	
