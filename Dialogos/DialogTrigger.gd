extends Area3D
class_name DialogTrigger

signal se_inicio_dialogo
signal se_termino_dialogo

@export var iniciar_al_colisionar := true
@export var requiere_boton_interactuar := false
@export var destruir_despues_de_usar := false
@export var reaccionar_solo_una_vez := true
@export var cooldown_segundos := 1.5



@export var lineas_dialogo: Array[String] = [
	"Hola.",
	"Esta es la línea 2."
]

var jugador_dentro := false
var ya_disparado := false
var en_cooldown := false


func _ready():
	if requiere_boton_interactuar and not iniciar_al_colisionar:
		add_to_group("Interactuable")

# -----------------------------
# 🚪 ÁREA
# -----------------------------
func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("Player"):
		return

	jugador_dentro = true
	DialogSystem.set_trigger_activo(self)


	if requiere_boton_interactuar and not iniciar_al_colisionar:
		DialogSystem.mostrar_interact()

	if iniciar_al_colisionar and not en_cooldown:
		trigger_dialog()


func _on_body_exited(body: Node) -> void:
	if not body.is_in_group("Player"):
		return

	jugador_dentro = false
	DialogSystem.clear_trigger(self)
	DialogSystem.ocultar_interact()


# -----------------------------
# 💬 DIÁLOGO
# -----------------------------
func trigger_dialog() -> void:
	if not jugador_dentro:
		return

	if reaccionar_solo_una_vez and ya_disparado:
		return

	if en_cooldown:
		return

	ya_disparado = true
	activar_cooldown()

	DialogSystem.ocultar_interact()
	DialogSystem.iniciar_dialogo(lineas_dialogo)
	emit_signal("se_inicio_dialogo")

	if destruir_despues_de_usar:
		remove_from_group("Interactuable")
		queue_free()


# -----------------------------
# ⏳ COOLDOWN
# -----------------------------
func activar_cooldown() -> void:
	en_cooldown = true
	get_tree().create_timer(cooldown_segundos).timeout.connect(
		func(): en_cooldown = false
	)


func puede_mostrar_interact() -> bool:
	# ❌ NO mostrar si inicia al colisionar
	if iniciar_al_colisionar:
		return false

	# ❌ NO mostrar si no requiere botón
	if not requiere_boton_interactuar:
		return false

	# ❌ NO mostrar si ya se usó
	if reaccionar_solo_una_vez and ya_disparado:
		return false

	# ❌ NO mostrar si está en cooldown
	if en_cooldown:
		return false

	return true
