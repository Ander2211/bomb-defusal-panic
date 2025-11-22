extends Node2D

signal minigame_success
signal minigame_failed

@onready var punto = $Punto
@onready var timer = $Timer
@onready var meta = $Meta
@onready var chocaste_panel = $chocast_panel

var posicion_inicial = Vector2.ZERO
var bloqueado := false


func _ready():
	posicion_inicial = punto.position
	chocaste_panel.visible = false

	timer.start()

	punto.connect("golpe_pared", Callable(self, "_on_golpe_pared"))
	meta.connect("body_entered", Callable(self, "_on_meta_body_entered"))


func _process(delta):
	if bloqueado:
		if Input.is_anything_pressed():  # cualquier tecla desbloquea
			desbloquear_juego()
		return


func _on_meta_body_entered(body):
	if body == punto:
		print("Meta alcanzada!")
		timer.stop()
		emit_signal("minigame_success")
		queue_free()


func _on_golpe_pared():
	print("Choque con pared!")
	chocar()


func chocar():
	bloqueado = true
	chocaste_panel.visible = true

	punto.freeze_point()
	punto.clear_trail()


func desbloquear_juego():
	bloqueado = false
	chocaste_panel.visible = false

	punto.position = posicion_inicial
	punto.unfreeze_point()
	timer.start()


func resetear_minijuego():
	chocaste_panel.visible = false
	bloqueado = false

	punto.position = posicion_inicial
	punto.unfreeze_point()
	punto.clear_trail()

	timer.start()


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"): # Backspace
		print("Salir minijuego...")
		emit_signal("minigame_failed")
		queue_free()
