extends TextureButton

var playing : bool

func _on_pressed() -> void:
	playing = not playing
	if playing:
		var index = AudioServer.get_bus_index("Master")
		AudioServer.set_bus_mute(index, true)
	else:
		var index = AudioServer.get_bus_index("Master")
		AudioServer.set_bus_mute(index, false)
