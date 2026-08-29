extends Area2D
class_name Goal

signal reached


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitoring = true
	body_entered.connect(_on_body)


func _on_body(body: Node) -> void:
	if body is Player:
		reached.emit()
