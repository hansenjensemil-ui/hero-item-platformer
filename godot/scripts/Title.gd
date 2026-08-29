extends Control


func _ready() -> void:
	$Backdrop.texture = Art.png("sky")
	$Hero.texture = Art.png("hero")
	$Hero.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	$Backdrop.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if event is InputEventKey and event.pressed:
		var k := event as InputEventKey
		if k.keycode == KEY_ENTER or k.keycode == KEY_SPACE or k.keycode == KEY_KP_ENTER:
			get_tree().change_scene_to_file("res://scenes/Level.tscn")
