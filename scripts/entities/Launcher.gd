extends Node2D
## Launcher-Entity für 50-Ball-Sequencing mit Aiming-System
##
## Erlaubt Spieler via Maus Schusswinkel zu wählen und spawnt 50 Bälle
## sequenziell mit präzisem Timing.

## Ball-Scene für Spawning
const BALL_SCENE: PackedScene = preload("res://scenes/entities/Ball.tscn")

## Anzahl Bälle pro Schuss
@export var ball_count: int = 50

## Delay zwischen Ball-Spawns in Sekunden
@export var spawn_delay: float = 0.1

## Minimaler Winkel in Grad (0° = rechts, -90° = oben, 90° = unten)
@export var min_angle: float = -150.0

## Maximaler Winkel in Grad
@export var max_angle: float = -30.0

## Länge der Aim-Line in Pixeln
@export var aim_line_length: float = 200.0

## Aktueller Zielwinkel in Radians
var current_angle: float = -PI / 2  # -90° default (nach oben)

## Ist Launcher aktiv (kann schießen)?
var is_active: bool = true

## Counter für gespawnte Bälle
var spawned_balls: int = 0

## Timer für Ball-Sequencing
var spawn_timer: Timer

## Referenzen zu Child-Nodes
var aim_line: Line2D
var spawn_marker: Marker2D

## Signals
signal shoot_requested(angle: float)
signal all_balls_spawned

func _ready() -> void:
	# Child-Nodes referenzieren
	aim_line = get_node_or_null("AimLine")
	spawn_marker = get_node_or_null("SpawnMarker")

	# Spawn-Timer erstellen
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_delay
	spawn_timer.one_shot = false
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)

	# Initial aim-line aktualisieren
	_update_aim_line()

func _input(event: InputEvent) -> void:
	if not is_active:
		return

	# Mouse Motion: Aim-Line aktualisieren
	if event is InputEventMouseMotion:
		var mouse_pos: Vector2 = get_global_mouse_position()
		var direction: Vector2 = (mouse_pos - global_position).normalized()

		# Winkel berechnen (atan2 gibt -PI bis PI zurück)
		var angle_rad: float = direction.angle()
		var angle_deg: float = rad_to_deg(angle_rad)

		# Winkel auf erlaubten Bereich limitieren
		# Für nach-oben-Schießen: -150° (links-oben) bis -30° (rechts-oben)
		angle_deg = clamp(angle_deg, min_angle, max_angle)

		current_angle = deg_to_rad(angle_deg)

		_update_aim_line()

	# Mouse Click: Schuss auslösen
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_shoot()

func _update_aim_line() -> void:
	"""Aktualisiert Line2D-Points basierend auf current_angle"""
	if not aim_line:
		return

	var direction: Vector2 = Vector2.from_angle(current_angle)
	var end_point: Vector2 = direction * aim_line_length

	aim_line.points = [Vector2.ZERO, end_point]

func _shoot() -> void:
	"""Startet 50-Ball-Sequenz"""
	if not is_active:
		return

	is_active = false
	spawned_balls = 0
	shoot_requested.emit(current_angle)

	# Ersten Ball sofort spawnen
	_spawn_single_ball()

	# Timer für restliche Bälle starten
	if ball_count > 1:
		spawn_timer.start()

func _spawn_single_ball() -> void:
	"""Spawnt einen einzelnen Ball mit aktuellem Winkel"""
	var ball: CharacterBody2D = BALL_SCENE.instantiate()

	# Ball-Position setzen (an Spawn-Marker oder Launcher-Position)
	if spawn_marker:
		ball.global_position = spawn_marker.global_position
	else:
		ball.global_position = global_position

	# Ball-Richtung setzen
	var direction: Vector2 = Vector2.from_angle(current_angle)
	ball.set_direction(direction)

	# Ball zur Scene-Tree hinzufügen
	# Versuche BallContainer im Parent zu finden, sonst Parent direkt
	var parent_node: Node = get_parent()
	var ball_container: Node = parent_node.get_node_or_null("BallContainer")

	if ball_container:
		ball_container.add_child(ball)
	else:
		parent_node.add_child(ball)

	spawned_balls += 1

func _on_spawn_timer_timeout() -> void:
	"""Timer-Callback: Spawnt nächsten Ball"""
	if spawned_balls >= ball_count:
		spawn_timer.stop()
		is_active = true
		all_balls_spawned.emit()
		return

	_spawn_single_ball()

func set_active(active: bool) -> void:
	"""Aktiviert/deaktiviert Launcher"""
	is_active = active

	# Aim-Line sichtbarkeit
	if aim_line:
		aim_line.visible = active

func get_current_angle() -> float:
	"""Gibt aktuellen Winkel in Radians zurück"""
	return current_angle
