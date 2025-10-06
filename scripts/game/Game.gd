extends Node2D
## Game-Orchestration Script
##
## Koordiniert alle Game-Entities (Launcher, Balls, Bricks) und
## managed den Core-Game-Loop mit Score-Tracking und Level-Completion.

## Container-Nodes
var ball_container: Node2D
var brick_container: Node2D
var launcher: Node2D

## Ball-Tracking
var active_balls: int = 0
var balls_returned: int = 0

## Level-Tracking
var total_bricks: int = 0
var destroyed_bricks: int = 0

func _ready() -> void:
	# Container-Nodes referenzieren
	ball_container = get_node_or_null("BallContainer")
	brick_container = get_node_or_null("BrickContainer")
	launcher = get_node_or_null("Launcher")

	# Launcher-Signals connecten
	if launcher:
		launcher.shoot_requested.connect(_on_launcher_shoot_requested)
		launcher.all_balls_spawned.connect(_on_all_balls_spawned)

	# Bricks zählen und Signals connecten
	_setup_bricks()

	# GameManager initialisieren
	GameManager.reset_level()

func _setup_bricks() -> void:
	"""Connectet alle Brick-Signals und zählt total_bricks"""
	if not brick_container:
		return

	total_bricks = 0
	for child in brick_container.get_children():
		if child.is_in_group("brick"):
			total_bricks += 1
			# destroyed-Signal connecten
			if child.has_signal("destroyed"):
				child.destroyed.connect(_on_brick_destroyed)

	print("Game: ", total_bricks, " bricks loaded")

func _on_launcher_shoot_requested(angle: float) -> void:
	"""Launcher hat Schuss angefordert - Attempts incrementieren"""
	GameManager.increment_attempts()
	print("Game: Attempt #", GameManager.attempts)

	# Launcher spawnt Bälle automatisch
	# Wir tracken nur die Anzahl
	active_balls = launcher.ball_count
	balls_returned = 0

func _on_all_balls_spawned() -> void:
	"""Alle 50 Bälle wurden gespawnt"""
	print("Game: All ", active_balls, " balls spawned")

	# Ball out-of-bounds Tracking einrichten
	_track_balls()

func _track_balls() -> void:
	"""Connectet out_of_bounds Signal für alle aktiven Bälle"""
	if not ball_container:
		return

	for child in ball_container.get_children():
		if child.has_signal("out_of_bounds"):
			# Check if not already connected
			if not child.out_of_bounds.is_connected(_on_ball_out_of_bounds):
				child.out_of_bounds.connect(_on_ball_out_of_bounds)

func _on_ball_out_of_bounds() -> void:
	"""Ball hat Screen verlassen"""
	balls_returned += 1

	# Check ob alle Bälle zurück sind
	if balls_returned >= active_balls:
		_on_all_balls_returned()

func _on_all_balls_returned() -> void:
	"""Alle Bälle sind out-of-bounds - Turn ist vorbei"""
	print("Game: All balls returned (", balls_returned, "/", active_balls, ")")

	# Check Level-Completion
	if _check_level_complete():
		_on_level_complete()
	else:
		# Launcher wieder aktivieren für nächsten Schuss
		if launcher:
			launcher.set_active(true)

func _on_brick_destroyed(points: int, brick_position: Vector2) -> void:
	"""Brick wurde zerstört - Score aktualisieren"""
	GameManager.add_score(points)
	destroyed_bricks += 1

	print("Game: Brick destroyed (+", points, " pts) | ", destroyed_bricks, "/", total_bricks)

	# Optional: Partikel-Effekt spawnen (später in M6)
	# _spawn_particle_effect(brick_position)

func _check_level_complete() -> bool:
	"""Prüft ob alle Bricks zerstört wurden"""
	return destroyed_bricks >= total_bricks

func _on_level_complete() -> void:
	"""Level wurde abgeschlossen"""
	print("Game: LEVEL COMPLETE! Score: ", GameManager.score, " | Attempts: ", GameManager.attempts)

	# GameManager-Signal emittieren
	GameManager.set_status("complete")

	# Highscore speichern
	var is_new_record: bool = ScoreManager.save_highscore(GameManager.current_level, GameManager.attempts)

	if is_new_record:
		print("Game: NEW RECORD! ", GameManager.attempts, " attempts")
	else:
		var best: int = ScoreManager.get_highscore(GameManager.current_level)
		print("Game: Best: ", best, " attempts")

	# Launcher deaktivieren
	if launcher:
		launcher.set_active(false)

	# TODO: UI-Feedback anzeigen (M5)

func restart_level() -> void:
	"""Startet aktuelles Level neu"""
	get_tree().reload_current_scene()

func get_active_balls_count() -> int:
	"""Gibt Anzahl aktiver Bälle zurück"""
	return active_balls - balls_returned
