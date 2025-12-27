extends Node

signal dialogo_iniciado(lineas: Array)
signal dialogo_terminado

var esta_hablando := false
var interaccion_bloqueada := false

var lineas_actuales: Array[String] = []
var indice := 0

var ui_dialogo: Node = null
var jugador: Node = null
var ui_interact: UIInteract = null

var trigger_activo: DialogTrigger = null


# -----------------------------
# 📌 REGISTROS
# -----------------------------
func registrar_ui(ui: Node) -> void:
	ui_dialogo = ui


func registrar_jugador(j: Node) -> void:
	jugador = j


func registrar_ui_interact(ui: UIInteract) -> void:
	ui_interact = ui


# -----------------------------
# 🎯 TRIGGER ACTIVO
# -----------------------------
func set_trigger_activo(trigger: DialogTrigger) -> void:
	trigger_activo = trigger


func clear_trigger(trigger: DialogTrigger) -> void:
	if trigger_activo == trigger:
		trigger_activo = null


# -----------------------------
# 🎮 INPUT GLOBAL (ÚNICO)
# -----------------------------
func _input(event: InputEvent) -> void:
	if not trigger_activo:
		return

	if esta_hablando:
		return

	if event.is_action_pressed("interact"):
		trigger_activo.trigger_dialog()


# -----------------------------
# 💬 DIÁLOGO
# -----------------------------
func iniciar_dialogo(lineas: Array[String]) -> void:
	if interaccion_bloqueada:
		return
	if esta_hablando:
		return
	if lineas.is_empty():
		return
	if ui_dialogo == null:
		push_error("DialogSystem: UI de diálogo no registrada")
		return

	esta_hablando = true
	lineas_actuales = lineas.duplicate()
	indice = 0

	if ui_interact:
		ui_interact.ocultar()

	if jugador and jugador.has_method("set_movement_enabled"):
		jugador.set_movement_enabled(false)

	ui_dialogo.show()
	ui_dialogo.mostrar_texto(lineas_actuales[indice])

	emit_signal("dialogo_iniciado", lineas_actuales)


func linea_siguiente() -> void:
	if not esta_hablando:
		return

	indice += 1

	if indice >= lineas_actuales.size():
		terminar_dialogo()
	else:
		ui_dialogo.mostrar_texto(lineas_actuales[indice])


func terminar_dialogo() -> void:
	if not esta_hablando:
		return

	esta_hablando = false
	lineas_actuales.clear()
	indice = 0

	if ui_dialogo:
		ui_dialogo.ocultar_dialogo()

	if jugador and jugador.has_method("set_movement_enabled"):
		jugador.set_movement_enabled(true)

	emit_signal("dialogo_terminado")


# -----------------------------
# 🖱️ ICONO INTERACTUAR
# -----------------------------
func mostrar_interact() -> void:
	if ui_interact:
		ui_interact.mostrar()


func ocultar_interact() -> void:
	if ui_interact:
		ui_interact.ocultar()
