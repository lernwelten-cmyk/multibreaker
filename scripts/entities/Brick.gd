extends StaticBody2D
## Brick-Entity mit HP-System und Destruction-Logic
##
## Bricks können mehrfach getroffen werden (HP-basiert) und emittieren
## Signals beim Destruction-Event für Score-Tracking.

## Brick-Trefferpunkte (1 = ein Treffer, 2 = zwei Treffer, etc.)
@export var hp: int = 1

## Punkte, die beim Zerstören vergeben werden
@export var points: int = 100

## Brick-Farbe (kann für visuelle HP-Anzeige genutzt werden)
@export var brick_color: Color = Color(0.29, 0.56, 0.89, 1.0)  # #4A90E2

## Signals für Event-Kommunikation
signal destroyed(points: int, brick_position: Vector2)
signal damaged(remaining_hp: int)

func _ready() -> void:
	# Brick zur "brick" Group hinzufügen für Collision-Detection
	add_to_group("brick")

	# Sprite-Farbe basierend auf HP setzen (falls vorhanden)
	_update_visual()

func take_damage(amount: int = 1) -> void:
	"""Reduziert HP und triggert Destruction bei hp <= 0"""
	hp -= amount

	if hp <= 0:
		_destroy()
	else:
		# Visual-Feedback: Farbe aufhellen basierend auf HP
		_update_visual()
		damaged.emit(hp)

func _destroy() -> void:
	"""Zerstört Brick und emittiert Signal mit Score-Daten"""
	destroyed.emit(points, global_position)
	queue_free()

func _update_visual() -> void:
	"""Aktualisiert visuelle Darstellung basierend auf HP"""
	var sprite := get_node_or_null("Sprite2D")
	if sprite and sprite is Sprite2D:
		# HP-basierte Transparenz: Je weniger HP, desto transparenter
		var alpha := clamp(float(hp) / 3.0, 0.4, 1.0)
		sprite.modulate = Color(brick_color.r, brick_color.g, brick_color.b, alpha)

func get_hp() -> int:
	"""Gibt aktuelle HP zurück"""
	return hp

func get_points() -> int:
	"""Gibt Punktwert zurück"""
	return points
