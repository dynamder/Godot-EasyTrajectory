extends Marker2D
@onready var move_object: Sprite2D = $"../MoveObject"

func _ready() -> void:
	position = move_object.position
