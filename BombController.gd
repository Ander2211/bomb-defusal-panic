extends Control
class_name BombsController

@onready var bombas_label: Label = $Bom
@onready var tiempo_label: Label = $TiempoLabel
@onready var nodo_bombas: Node3D = get_node("../Bombas")

# Cargar escena del panel de resultados - VERIFICA LA RUTA
var resultados_panel_scene = preload("res://resultados_panel.tscn")
var resultados_panel_instance = null

var tiempo_inicio: float = 0.0
var tiempo_final: float = 0.0
var tiempo_detenido: bool = false
var bombas_totales: int = 0
var bombas_desactivadas: int = 0
var bombas_explotadas: int = 0
var juego_terminado: bool = false

func _ready():
	# Configurar mouse capturado al inicio del juego
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	print("Mouse capturado para jugar")
	
	# Buscar nodo Bombas
	if nodo_bombas:
		print("✅ Nodo Bombas encontrado con ", nodo_bombas.get_child_count(), " hijos")
		
		# Conectar señales de todas las bombas
		for bomba in nodo_bombas.get_children():
			if bomba is Bomb:
				# Desconectar primero para evitar duplicados
				if bomba.bomb_defused.is_connected(_on_bomba_desactivada):
					bomba.bomb_defused.disconnect(_on_bomba_desactivada)
				if bomba.bomb_exploded.is_connected(_on_bomba_explodida):
					bomba.bomb_exploded.disconnect(_on_bomba_explodida)
				
				bomba.bomb_defused.connect(_on_bomba_desactivada)
				bomba.bomb_exploded.connect(_on_bomba_explodida)
				bombas_totales += 1
				print("  ✅ Bomba conectada: ", bomba.name)
	else:
		print("❌ ERROR: No se encontró el nodo Bombas")
	
	print("Total de bombas encontradas: ", bombas_totales)
	
	actualizar_contador()
	tiempo_inicio = Time.get_ticks_msec()

func _process(delta):
	if not tiempo_detenido and not juego_terminado:
		var tiempo_transcurrido = (Time.get_ticks_msec() - tiempo_inicio) / 1000.0
		actualizar_tiempo_ui(tiempo_transcurrido)

func actualizar_contador():
	var bombas_activas = 0
	bombas_desactivadas = 0
	bombas_explotadas = 0
	
	if nodo_bombas:
		for bomba in nodo_bombas.get_children():
			if bomba is Bomb:
				if bomba.is_active:
					bombas_activas += 1
				else:
					# Contar si fue desactivada o explotada
					if bomba.bomb_light.light_color == Color.GREEN:
						bombas_desactivadas += 1
					else:
						bombas_explotadas += 1
	
	bombas_label.text = "Bombas: " + str(bombas_activas) + "/" + str(bombas_totales)
	
	print("Contador actualizado: ", bombas_activas, " activas de ", bombas_totales)
	
	# Detener tiempo cuando no haya bombas activas
	if bombas_activas == 0 and bombas_totales > 0 and not juego_terminado:
		finalizar_juego()

func actualizar_tiempo_ui(tiempo: float):
	var minutos = int(tiempo) / 60
	var segundos = int(tiempo) % 60
	tiempo_label.text = "%02d:%02d" % [minutos, segundos]

func finalizar_juego():
	if juego_terminado:
		return
	
	juego_terminado = true
	tiempo_detenido = true
	tiempo_final = (Time.get_ticks_msec() - tiempo_inicio) / 1000.0
	
	# Mostrar tiempo final en verde
	tiempo_label.add_theme_color_override("font_color", Color.GREEN)
	
	print("¡Juego terminado!")
	print("Tiempo total: ", get_tiempo_formateado(tiempo_final))
	print("Bombas desactivadas: ", bombas_desactivadas)
	print("Bombas explotadas: ", bombas_explotadas)
	
	# Mostrar panel de resultados
	mostrar_panel_resultados()

func mostrar_panel_resultados():
	# Verificar que la escena existe
	if not resultados_panel_scene:
		print("❌ ERROR: No se pudo cargar resultados_panel.tscn")
		return
	
	# Instanciar el panel de resultados
	resultados_panel_instance = resultados_panel_scene.instantiate()
	
	# Verificar que la instancia es válida
	if not resultados_panel_instance:
		print("❌ ERROR: No se pudo instanciar el panel de resultados")
		# Crear panel dinámicamente como respaldo
		crear_panel_dinamicamente()
		return
	
	add_child(resultados_panel_instance)
	
	# CONEXIÓN SEGURA DE SEÑALES
	# IMPORTANTE: Conectar señales usando callables para evitar errores
	if resultados_panel_instance.has_signal("volver_a_menu"):
		resultados_panel_instance.volver_a_menu.connect(volver_al_menu)
		print("✅ Señal 'volver_a_menu' conectada")
	else:
		print("⚠️ El panel no tiene señal 'volver_a_menu', usando respaldo")
		# Conectar directamente a los botones
		conectar_botones_directamente(resultados_panel_instance)
	
	if resultados_panel_instance.has_signal("reiniciar_juego"):
		resultados_panel_instance.reiniciar_juego.connect(reiniciar_escena)
		print("✅ Señal 'reiniciar_juego' conectada")
	
	# Llamar a la función mostrar_resultados si existe
	if resultados_panel_instance.has_method("mostrar_resultados"):
		resultados_panel_instance.mostrar_resultados(
			tiempo_final,
			bombas_desactivadas,
			bombas_explotadas,
			bombas_totales
		)
		print("✅ Método 'mostrar_resultados' llamado")
	else:
		print("❌ ERROR: El panel no tiene método 'mostrar_resultados'")
		# Actualizar panel dinámico
		actualizar_panel_dinamico(resultados_panel_instance)
	
	print("✅ Panel de resultados creado - Cursor visible")

func conectar_botones_directamente(panel):
	# Buscar botones y conectar directamente
	var menu_btn = panel.get_node_or_null("Panel/VBoxContainer/HBoxContainer/MenuPrincipal")
	var reiniciar_btn = panel.get_node_or_null("Panel/VBoxContainer/HBoxContainer/Reiniciar")
	
	if menu_btn:
		if menu_btn.pressed.is_connected(volver_al_menu):
			menu_btn.pressed.disconnect(volver_al_menu)
		menu_btn.pressed.connect(volver_al_menu)
		print("✅ Botón Menú conectado directamente")
	
	if reiniciar_btn:
		if reiniciar_btn.pressed.is_connected(reiniciar_escena):
			reiniciar_btn.pressed.disconnect(reiniciar_escena)
		reiniciar_btn.pressed.connect(reiniciar_escena)
		print("✅ Botón Reiniciar conectado directamente")

func crear_panel_dinamicamente():
	# Crear CanvasLayer
	resultados_panel_instance = CanvasLayer.new()
	resultados_panel_instance.layer = 100
	add_child(resultados_panel_instance)
	
	# Crear Panel
	var panel = Panel.new()
	panel.name = "Panel"
	panel.size = Vector2(400, 300)
	panel.position = Vector2(200, 150)
	
	# Crear VBoxContainer
	var vbox = VBoxContainer.new()
	vbox.name = "VBoxContainer"
	vbox.size = Vector2(380, 280)
	vbox.position = Vector2(10, 10)
	
	# Crear Labels
	var tiempo_label = Label.new()
	tiempo_label.name = "TiempoLabel"
	vbox.add_child(tiempo_label)
	
	var desactivadas_label = Label.new()
	desactivadas_label.name = "DesactivadasLabel"
	vbox.add_child(desactivadas_label)
	
	var explotadas_label = Label.new()
	explotadas_label.name = "ExplotadasLabel"
	vbox.add_child(explotadas_label)
	
	var calificacion_label = Label.new()
	calificacion_label.name = "CalificacionLabel"
	vbox.add_child(calificacion_label)
	
	# Crear botones
	var hbox = HBoxContainer.new()
	hbox.name = "HBoxContainer"
	vbox.add_child(hbox)
	
	var menu_btn = Button.new()
	menu_btn.name = "MenuPrincipal"
	menu_btn.text = "Menú Principal"
	menu_btn.custom_minimum_size = Vector2(150, 40)
	menu_btn.pressed.connect(volver_al_menu)
	hbox.add_child(menu_btn)
	
	var reiniciar_btn = Button.new()
	reiniciar_btn.name = "Reiniciar"
	reiniciar_btn.text = "Reiniciar"
	reiniciar_btn.custom_minimum_size = Vector2(150, 40)
	reiniciar_btn.pressed.connect(reiniciar_escena)
	hbox.add_child(reiniciar_btn)
	
	# Añadir a la jerarquía
	panel.add_child(vbox)
	resultados_panel_instance.add_child(panel)
	
	# Actualizar textos
	actualizar_panel_dinamico(resultados_panel_instance)
	
	# Estilo
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	style.border_color = Color(0.5, 0.5, 0.5)
	style.border_width_all = 4
	style.corner_radius_top_left = 20
	style.corner_radius_top_right = 20
	style.corner_radius_bottom_left = 20
	style.corner_radius_bottom_right = 20
	panel.add_theme_stylebox_override("panel", style)
	
	print("✅ Panel creado dinámicamente")

func actualizar_panel_dinamico(panel_instance):
	var tiempo_label = panel_instance.get_node_or_null("Panel/VBoxContainer/TiempoLabel")
	var desactivadas_label = panel_instance.get_node_or_null("Panel/VBoxContainer/DesactivadasLabel")
	var explotadas_label = panel_instance.get_node_or_null("Panel/VBoxContainer/ExplotadasLabel")
	var calificacion_label = panel_instance.get_node_or_null("Panel/VBoxContainer/CalificacionLabel")
	
	if tiempo_label:
		var minutos = int(tiempo_final) / 60
		var segundos = int(tiempo_final) % 60
		tiempo_label.text = "Tiempo: %02d:%02d" % [minutos, segundos]
	
	if desactivadas_label:
		desactivadas_label.text = "Bombas desactivadas: " + str(bombas_desactivadas) + "/" + str(bombas_totales)
	
	if explotadas_label:
		explotadas_label.text = "Bombas explotadas: " + str(bombas_explotadas) + "/" + str(bombas_totales)
	
	if calificacion_label:
		var calificacion = calcular_calificacion()
		calificacion_label.text = "Calificación: " + str(calificacion) + "/10"

func calcular_calificacion() -> int:
	if bombas_totales == 0:
		return 0
	
	var puntaje = 0.0
	
	# Puntos por bombas desactivadas (50%)
	puntaje += (float(bombas_desactivadas) / bombas_totales) * 5.0
	
	# Puntos por evitar explosiones (30%)
	puntaje += (float(bombas_totales - bombas_explotadas) / bombas_totales) * 3.0
	
	# Puntos por tiempo (20%) - menos tiempo = más puntos
	var tiempo_ideal = 30.0 * bombas_totales  # 30 segundos por bomba
	var tiempo_factor = clamp(1.0 - (tiempo_final / tiempo_ideal), 0.0, 1.0)
	puntaje += tiempo_factor * 2.0
	
	# Redondear al entero más cercano
	return int(round(puntaje))

func volver_al_menu():
	print("Volviendo al menú principal...")
	# Cambiar a la escena del menú principal
	get_tree().change_scene_to_file("res://inicio.tscn")

func reiniciar_escena():
	print("Reiniciando juego...")
	# Recargar la escena actual
	get_tree().reload_current_scene()

func _on_bomba_desactivada(bomba: Bomb):
	print("📢 Bomba desactivada: ", bomba.name)
	await get_tree().create_timer(0.1).timeout
	actualizar_contador()

func _on_bomba_explodida(bomba: Bomb):
	print("💥 Bomba explotada: ", bomba.name)
	await get_tree().create_timer(0.1).timeout
	actualizar_contador()

func get_tiempo_formateado(tiempo: float) -> String:
	var minutos = int(tiempo) / 60
	var segundos = int(tiempo) % 60
	return "%02d:%02d" % [minutos, segundos]
