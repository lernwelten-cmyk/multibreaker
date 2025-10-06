extends CanvasLayer
## HUD (Heads-Up Display) für Score & Attempts
##
## Zeigt aktuellen Score, Attempts-Counter und Level-Informationen an.

## Label-Referenzen
var score_label: Label
var attempts_label: Label
var level_label: Label

func _ready() -> void:
	# Labels referenzieren
	score_label = get_node_or_null("Control/ScoreLabel")
	attempts_label = get_node_or_null("Control/AttemptsLabel")
	level_label = get_node_or_null("Control/LevelLabel")

	# GameManager-Signals connecten
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.attempts_incremented.connect(_on_attempts_changed)

	# Initial update
	_update_ui()

func _update_ui() -> void:
	"""Aktualisiert alle UI-Elemente"""
	_on_score_changed(GameManager.score)
	_on_attempts_changed(GameManager.attempts)
	_update_level_label()

func _on_score_changed(new_score: int) -> void:
	"""Score hat sich geändert"""
	if score_label:
		score_label.text = "Score: " + str(new_score)

func _on_attempts_changed(new_attempts: int) -> void:
	"""Attempts-Counter hat sich geändert"""
	if attempts_label:
		attempts_label.text = "Attempts: " + str(new_attempts)

func _update_level_label() -> void:
	"""Aktualisiert Level-Anzeige"""
	if level_label:
		level_label.text = "Level " + str(GameManager.current_level)

		# Highscore anzeigen (falls vorhanden)
		var best: int = ScoreManager.get_highscore(GameManager.current_level)
		if best > 0:
			level_label.text += " (Best: " + str(best) + ")"
