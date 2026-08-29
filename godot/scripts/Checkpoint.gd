extends Area2D
class_name Checkpoint

signal activated(pos: Vector2)

var used_once: bool = false


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitoring = true
	body_entered.connect(_on_body)


func _on_body(body: Node) -> void:
	if body is Player:
		var p := body as Player
		var feet := Vector2(global_position.x, global_position.y)
		activated.emit(feet)
		if not used_once:
			used_once = true
			p.toasted.emit("Checkpoint reached", Color(0.49, 0.87, 0.65))
