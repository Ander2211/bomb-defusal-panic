# DialogUI.gd
extends Control

@onready var etiqueta: RichTextLabel = $RichTextLabel

@export var usar_typewriter: bool = true
@export var velocidad_typewriter: float = 0.02

var _texto_completo := ""
var _typing := false
var _skip := false


func _ready() -> void:
	hide()
	DialogSystem.registrar_ui(self)


func mostrar_texto(texto: String) -> void:
	_texto_completo = texto
	_skip = false

	if usar_typewriter:
		etiqueta.text = ""
		show()
		_typewriter()
	else:
		etiqueta.text = texto
		show()


func _typewriter() -> void:
	_typing = true
	for i in _texto_completo.length():
		if _skip:
			etiqueta.text = _texto_completo
			break

		etiqueta.text += _texto_completo[i]
		await get_tree().create_timer(velocidad_typewriter).timeout

	_typing = false


func ocultar_dialogo() -> void:
	hide()
	_typing = false
	_skip = false


func _input(event: InputEvent) -> void:
	if not DialogSystem.esta_hablando:
		return

	if event.is_action_pressed("interact"):
		if _typing:
			_skip = true
		else:
			DialogSystem.linea_siguiente()
