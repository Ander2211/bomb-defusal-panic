extends Control

@onready var anim = $AnimationPlayer
@onready var fade_rect = $ColorRect

var scene_to_load := ""
var progress := []  # debe ser un Array vacío
var is_fading_out := false

func start_loading(path):
	scene_to_load = path

	# Fade in para mostrar pantalla de carga
	#fade_in()

	# Animación en loop
	anim.play("Cargando")

	# Empieza carga real (en thread)
	ResourceLoader.load_threaded_request(scene_to_load)

	set_process(true)


func _process(delta):
	if scene_to_load == "":
		return

	var status = ResourceLoader.load_threaded_get_status(scene_to_load, progress)

	match status:
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
			print("Progreso:", progress[0])
			pass

		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			if not is_fading_out:
				is_fading_out = true
				fade_out()

		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
			print("ERROR cargando la escena.")


# -------------------------------------------------------
#                EFECTO FADE IN / OUT
# -------------------------------------------------------

func fade_in():
	fade_rect.modulate.a = 1.0
	fade_rect.create_tween().tween_property(fade_rect, "modulate:a", 0.0, 1.0)


func fade_out():
	var tween = fade_rect.create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 1.0)

	tween.finished.connect(_finish_load)


func _finish_load():
	var new_scene = ResourceLoader.load_threaded_get(scene_to_load)
	get_tree().change_scene_to_packed(new_scene)
