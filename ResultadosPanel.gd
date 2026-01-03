# ResultadosPanel.gd
extends CanvasLayer

# SEÑALES - DEBEN ESTAR DEFINIDAS
signal volver_a_menu
signal reiniciar_juego

# Variables para evitar errores de referencia null
var tiempo_label: Label
var desactivadas_label: Label
var explotadas_label: Label
var calificacion_label: Label
var menu_btn: Button
var reiniciar_btn: Button

func _ready():
	# Activar cursor inmediatamente
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	print("✅ Panel inicializado - Cursor visible")
	
	# Buscar nodos
	buscar_nodos()
	
	# Conectar botones
	conectar_botones()
	
	# Configurar estilo del panel
	configurar_estilo_panel()
	
	# Ocultar panel inicialmente
	visible = false

func buscar_nodos():
	# Buscar labels usando nombres más flexibles
	tiempo_label = get_node_or_null("Panel/VBoxContainer/TiempoLabel")
	desactivadas_label = get_node_or_null("Panel/VBoxContainer/DesactivadasLabel")
	explotadas_label = get_node_or_null("Panel/VBoxContainer/ExplotadasLabel")
	calificacion_label = get_node_or_null("Panel/VBoxContainer/CalificacionLabel")
	
	# Buscar botones con diferentes nombres posibles
	menu_btn = get_node_or_null("Panel/VBoxContainer/HBoxContainer/MenuPrincipal")
	if not menu_btn:
		menu_btn = get_node_or_null("Panel/VBoxContainer/HBoxContainer/Menu")
	if not menu_btn:
		menu_btn = get_node_or_null("Panel/VBoxContainer/HBoxContainer/Menú Principal")
	
	reiniciar_btn = get_node_or_null("Panel/VBoxContainer/HBoxContainer/Reiniciar")
	if not reiniciar_btn:
		reiniciar_btn = get_node_or_null("Panel/VBoxContainer/HBoxContainer/ReiniciarBtn")
	
	# Crear nodos si no existen
	crear_nodos_si_faltan()

func crear_nodos_si_faltan():
	var vbox = get_node_or_null("Panel/VBoxContainer")
	var hbox = get_node_or_null("Panel/VBoxContainer/HBoxContainer")
	
	if not vbox:
		return
	
	# Crear labels si faltan
	if not tiempo_label:
		tiempo_label = Label.new()
		tiempo_label.name = "TiempoLabel"
		vbox.add_child(tiempo_label)
	
	if not desactivadas_label:
		desactivadas_label = Label.new()
		desactivadas_label.name = "DesactivadasLabel"
		vbox.add_child(desactivadas_label)
	
	if not explotadas_label:
		explotadas_label = Label.new()
		explotadas_label.name = "ExplotadasLabel"
		vbox.add_child(explotadas_label)
	
	if not calificacion_label:
		calificacion_label = Label.new()
		calificacion_label.name = "CalificacionLabel"
		vbox.add_child(calificacion_label)
	
	# Crear HBoxContainer para botones si no existe
	if not hbox:
		hbox = HBoxContainer.new()
		hbox.name = "HBoxContainer"
		vbox.add_child(hbox)
	
	# Crear botones si faltan
	if not menu_btn:
		menu_btn = Button.new()
		menu_btn.name = "MenuPrincipal"
		menu_btn.text = "Menú Principal"
		menu_btn.custom_minimum_size = Vector2(150, 40)
		hbox.add_child(menu_btn)
	
	if not reiniciar_btn:
		reiniciar_btn = Button.new()
		reiniciar_btn.name = "Reiniciar"
		reiniciar_btn.text = "Reiniciar"
		reiniciar_btn.custom_minimum_size = Vector2(150, 40)
		hbox.add_child(reiniciar_btn)

func conectar_botones():
	# Conectar botones - IMPORTANTE: usar lambda si hay problemas
	if menu_btn:
		# Desconectar primero para evitar duplicados
		if menu_btn.pressed.is_connected(_on_menu_principal_pressed):
			menu_btn.pressed.disconnect(_on_menu_principal_pressed)
		
		# Conectar usando lambda para evitar errores
		menu_btn.pressed.connect(_on_menu_principal_pressed)
		print("✅ Botón Menú conectado")
	
	if reiniciar_btn:
		# Desconectar primero para evitar duplicados
		if reiniciar_btn.pressed.is_connected(_on_reiniciar_pressed):
			reiniciar_btn.pressed.disconnect(_on_reiniciar_pressed)
		
		# Conectar usando lambda para evitar errores
		reiniciar_btn.pressed.connect(_on_reiniciar_pressed)
		print("✅ Botón Reiniciar conectado")

func configurar_estilo_panel():
	var panel = get_node_or_null("Panel")
	if panel:
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.1, 0.1, 0.1, 0.95)
		style.border_color = Color(0.5, 0.5, 0.5)
		style.border_width_bottom = 4
		style.border_width_top = 4
		style.border_width_left = 4
		style.border_width_right = 4
		style.corner_radius_top_left = 20
		style.corner_radius_top_right = 20
		style.corner_radius_bottom_left = 20
		style.corner_radius_bottom_right = 20
		panel.add_theme_stylebox_override("panel", style)

func mostrar_resultados(tiempo_total: float, desactivadas: int, explotadas: int, total_bombas: int):
	# Asegurarse de que el cursor esté visible
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Verificar que los labels existen
	if not tiempo_label or not desactivadas_label or not explotadas_label or not calificacion_label:
		print("⚠️ Algunos labels no están inicializados. Reinicializando...")
		buscar_nodos()
	
	# Mostrar tiempo
	var minutos = int(tiempo_total) / 60
	var segundos = int(tiempo_total) % 60
	tiempo_label.text = "Tiempo: %02d:%02d" % [minutos, segundos]
	
	# Mostrar estadísticas
	desactivadas_label.text = "Bombas desactivadas: " + str(desactivadas) + "/" + str(total_bombas)
	explotadas_label.text = "Bombas explotadas: " + str(explotadas) + "/" + str(total_bombas)
	
	# Calcular calificación (1-10)
	var calificacion = calcular_calificacion(desactivadas, explotadas, total_bombas, tiempo_total)
	calificacion_label.text = "Calificación: " + str(calificacion) + "/10"
	
	# Mostrar panel
	visible = true
	
	# Enfocar el botón de menú para navegación con teclado
	if menu_btn:
		menu_btn.grab_focus()
	
	print("✅ Panel de resultados mostrado")

func calcular_calificacion(desactivadas: int, explotadas: int, total: int, tiempo: float) -> int:
	if total == 0:
		return 0
	
	var puntaje = 0.0
	
	# Sistema de calificación:
	# - 50% por bombas desactivadas (5 puntos máximo)
	# - 30% por evitar explosiones (3 puntos máximo)
	# - 20% por tiempo (2 puntos máximo)
	
	puntaje += (float(desactivadas) / total) * 5.0
	puntaje += (float(total - explotadas) / total) * 3.0
	
	var tiempo_ideal = 30.0 * total  # 30 segundos por bomba
	var tiempo_factor = clamp(1.0 - (tiempo / tiempo_ideal), 0.0, 1.0)
	puntaje += tiempo_factor * 2.0
	
	# Redondear al entero más cercano
	return int(round(puntaje))

func _on_menu_principal_pressed():
	print("✅ Botón 'Menú Principal' presionado")
	# Emitir señal
	volver_a_menu.emit()

func _on_reiniciar_pressed():
	print("✅ Botón 'Reiniciar' presionado")
	# Emitir señal
	reiniciar_juego.emit()

func _process(delta):
	# Si el panel está visible, asegurarse de que el cursor esté visible
	if visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
