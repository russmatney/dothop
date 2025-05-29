extends GPUParticles2D

# ref: https://www.youtube.com/watch?v=vP-xnJhwzsM

func _ready() -> void:
	var canvas := get_canvas_transform()
	var top_left := -canvas.origin / canvas.get_scale()
	var rect := get_viewport_rect()
	var size := rect.size / canvas.get_scale()

	# center the effect
	global_position.x = top_left.x + size.x / 2
	global_position.y = top_left.y + size.y / 2

	if process_material is ParticleProcessMaterial:
		var mat: ParticleProcessMaterial = process_material
		Log.pr("setting box extents", Vector3(size.x, size.y, 1.0))
		mat.set_emission_box_extents(Vector3(size.x, size.y, 1.0))
