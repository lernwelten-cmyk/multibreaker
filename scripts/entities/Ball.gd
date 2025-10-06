extends CharacterBody2D
## Ball-Entity mit Spiegelreflexions-Physics
##
## Bewegt sich mit konstanter Geschwindigkeit und reflektiert an Kollisionsobjekten.
## Emittiert Signals bei Kollisionen und Out-of-Bounds.

## Ball-Geschwindigkeit in Pixeln pro Sekunde
@export var speed: float = 500.0

## Viewport-Größe für Out-of-Bounds Detection
var viewport_size: Vector2

## Signals für Event-Kommunikation
signal collided_with_brick(brick: Node2D)
signal collided_with_wall
signal out_of_bounds

func _ready() -> void:
	# Viewport-Größe cachen
	viewport_size = get_viewport_rect().size

	# Initial velocity setzen (wird von außen überschrieben)
	if velocity == Vector2.ZERO:
		# Fallback: 45° nach rechts-unten
		velocity = Vector2(1, 1).normalized() * speed

func _physics_process(delta: float) -> void:
	# Out-of-Bounds Check (Ball hat Screen verlassen)
	if _is_out_of_bounds():
		out_of_bounds.emit()
		queue_free()
		return

	# Ball bewegen mit Kollisions-Detection
	var collision := move_and_collide(velocity * delta)

	if collision:
		_handle_collision(collision)

func _is_out_of_bounds() -> bool:
	"""Prüft, ob Ball außerhalb des sichtbaren Bereichs ist"""
	return (
		position.x < -50 or
		position.x > viewport_size.x + 50 or
		position.y < -50 or
		position.y > viewport_size.y + 50
	)

func _handle_collision(collision: KinematicCollision2D) -> void:
	"""Verarbeitet Kollision und emittiert passende Signals"""
	var collider := collision.get_collider()

	# Spiegelreflexion: Velocity an Normal-Vektor reflektieren
	velocity = velocity.bounce(collision.get_normal())

	# Signal emittieren basierend auf Collider-Typ
	if collider.is_in_group("brick"):
		collided_with_brick.emit(collider)
	elif collider.is_in_group("wall"):
		collided_with_wall.emit()

func set_direction(direction: Vector2) -> void:
	"""Setzt Ball-Richtung (wird von Launcher aufgerufen)"""
	velocity = direction.normalized() * speed

func get_speed() -> float:
	"""Gibt aktuelle Geschwindigkeit zurück"""
	return speed
