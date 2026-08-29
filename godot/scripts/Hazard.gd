extends Area2D
class_name Hazard

@export var damage: int = 2
@export var knock_up: float = 300.0


func _ready() -> void:
	collision_layer = 32
	collision_mask = 2
	monitoring = true
	body_entered.connect(_on_body)


func _on_body(body: Node) -> void:
	if body is Player:
		var p := body as Player
		var kx := -signf(p.velocity.x) * 120.0
		if kx == 0.0:
			kx = -80.0
		p.take_damage(damage, kx)
		p.velocity.y = -knock_up
