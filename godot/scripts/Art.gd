extends Node
## Loads original sprites from PNG on disk, or from ASCII base64 fallbacks.

var _cache := {}


func png(name: String) -> Texture2D:
	var path := "res://assets/%s.png" % name
	if ResourceLoader.exists(path):
		return load(path)
	return tex(name)


func tex(name: String) -> Texture2D:
	if _cache.has(name):
		return _cache[name]
	var b64_path := "res://assets/b64/%s.b64" % name
	if not FileAccess.file_exists(b64_path):
		push_error("Art: missing %s" % name)
		return null
	var f := FileAccess.open(b64_path, FileAccess.READ)
	var b64 := f.get_as_text().strip_edges()
	var buf := Marshalls.base64_to_raw(b64)
	var img := Image.new()
	if img.load_png_from_buffer(buf) != OK:
		push_error("Art: failed to decode %s" % name)
		return null
	var t := ImageTexture.create_from_image(img)
	_cache[name] = t
	return t
