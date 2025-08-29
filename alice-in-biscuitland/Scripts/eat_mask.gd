extends AnimatedSprite2D

@onready var eat_animation: AnimationPlayer = $"../Eat Animation"

func start_mask() -> void:
	clip_children = CanvasItem.CLIP_CHILDREN_ONLY
	modulate = Color(1, 1, 1, 1)
	frame = 0
	
	
func step() -> void:
	frame += 1
	
func end() -> void:
	frame = 3
	modulate = Color(1, 1, 1, 0)
	clip_children = CanvasItem.CLIP_CHILDREN_DISABLED
