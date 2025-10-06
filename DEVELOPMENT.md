# Entwicklungsrichtlinien (Godot 4)

> **Wichtig für AI-Assistenten (Claude Code):** Diese Datei enthält verbindliche Architektur- und Entwicklungsrichtlinien für dieses Godot-Projekt. Bitte lies und befolge diese Regeln bei jeder Code-Änderung.

---

## 🏗️ Architektur-Prinzipien

### Modularer "Lego-Baustein" Ansatz
- **Jede Scene/Script ist ein eigenständiger, isolierter Baustein**
- Komponenten haben klar definierte Schnittstellen (Signals, @export)
- Keine versteckten Abhängigkeiten zwischen Modulen
- Wiederverwendbarkeit durch klare Abstraktion

### Single Responsibility Principle
- Jede Datei/Scene hat **genau eine Aufgabe**
- Große Scripts werden in kleinere aufgeteilt
- Business-Logic getrennt von UI-Komponenten
- Maximale Dateigröße: **200-250 Zeilen**

### Komponenten-Isolation
```gdscript
# ✅ Gut: Scenes kommunizieren über Signals
signal brick_destroyed(points: int)
destroyed.emit(100)

# ❌ Schlecht: Direkte Node-Referenzen zwischen Features
var game_manager = get_node("/root/Game/Manager")  # ❌
```

---

## 📁 Projekt-Struktur

```
multiballbraker/
├── scenes/                    # Godot-Scenes (.tscn)
│   ├── main/
│   │   ├── Main.tscn         # Root-Scene
│   │   └── Main.gd
│   ├── game/                 # Game-Scenes
│   │   ├── Game.tscn
│   │   └── Game.gd
│   ├── entities/             # Wiederverwendbare Game-Objekte
│   │   ├── Ball.tscn
│   │   ├── Ball.gd
│   │   ├── Brick.tscn
│   │   └── Brick.gd
│   ├── ui/                   # UI-Komponenten
│   │   ├── HUD.tscn
│   │   ├── MainMenu.tscn
│   │   └── ...
│   └── levels/               # Level-Layouts
│       ├── Level01.tscn
│       └── ...
│
├── scripts/                  # Pure GDScript (keine Scene-Attachments)
│   ├── autoload/             # Singleton-Scripts (Global State)
│   │   ├── GameManager.gd
│   │   ├── AudioManager.gd
│   │   └── ScoreManager.gd
│   ├── systems/              # Wiederverwendbare Systeme
│   │   ├── CollisionSystem.gd
│   │   └── LevelGenerator.gd
│   └── utils/                # Helper-Functions (Pure Functions)
│       ├── Math.gd
│       └── SaveLoad.gd
│
├── resources/                # Godot Custom Resources (.tres)
│   ├── level_data/
│   │   └── LevelData.gd
│   └── brick_types/
│       └── BrickType.gd
│
├── assets/                   # Art, Audio, Fonts
│   ├── sprites/
│   ├── sounds/
│   ├── fonts/
│   └── particles/
│
└── tests/                    # Unit-Tests (GUT Framework)
    └── unit/
```

### Ordner-Konventionen
- **scenes/**: Godot-Scenes (.tscn) mit attached Scripts
- **scripts/autoload/**: Singleton-Scripts (via Project Settings konfiguriert)
- **scripts/systems/**: Wiederverwendbare Systeme ohne Scene-Attachment
- **scripts/utils/**: Pure Functions ohne Side-Effects
- **resources/**: Custom Resource-Klassen (.gd) und Instances (.tres)
- **assets/**: Alle Art-/Audio-Assets

---

## 🔧 Code-Änderungs-Regeln

### ⚠️ KRITISCH: Scope-Limitation

**Bei jeder Code-Änderung:**

1. **Ändere NUR die explizit angefragten Dateien**
2. **Keine "Optimierungen" an anderen Stellen** ohne Rückfrage
3. **Frage nach, wenn andere Dateien betroffen sind**
4. **Keine automatischen Refactorings** außerhalb des Scope

**Beispiel:**
```
Aufgabe: "Füge HP-Anzeige zum Brick hinzu"

✅ Ändern:
   - scenes/entities/Brick.tscn (Label hinzufügen)
   - scenes/entities/Brick.gd (Label-Update-Logic)

❌ NICHT ändern ohne zu fragen:
   - Andere Entities
   - GameManager
   - UI-Komponenten
```

### Neue Features
```
Neue Features = Neue Scenes/Scripts

❌ Bestehende Scripts erweitern (außer minimal)
✅ Neue isolierte Scenes/Scripts erstellen
```

---

## 🔗 Komponenten-Kommunikation

### Erlaubte Kommunikationswege

**1. Signals (Child → Parent)**
```gdscript
# ✅ Gut: Loose Coupling via Signals
# Brick.gd
signal destroyed(points: int, position: Vector2)

func take_damage():
    hp -= 1
    if hp <= 0:
        destroyed.emit(100, global_position)
        queue_free()

# Game.gd
func _ready():
    for brick in get_tree().get_nodes_in_group("bricks"):
        brick.destroyed.connect(_on_brick_destroyed)

func _on_brick_destroyed(points: int, pos: Vector2):
    GameManager.add_score(points)
```

**2. @export Properties (Parent → Child)**
```gdscript
# ✅ Gut: Konfigurierbare Properties
extends StaticBody2D

@export var hp: int = 1
@export var points: int = 100
@export var color: Color = Color.RED
```

**3. Autoload (Globaler State)**
```gdscript
# ✅ Gut: Für echten globalen State
GameManager.current_level
AudioManager.play_sfx("brick_break")
ScoreManager.get_highscore(1)
```

**4. Groups (Tagging-System)**
```gdscript
# ✅ Gut: Nodes nach Gruppen finden
var all_bricks = get_tree().get_nodes_in_group("bricks")
var all_balls = get_tree().get_nodes_in_group("balls")
```

### Verbotene Patterns

```gdscript
# ❌ Direkte Pfad-Referenzen zwischen Features
var launcher = get_node("/root/Game/Launcher")  # ❌

# ❌ Globale Variablen (außer Autoload)
var global_score = 0  # ❌ (Use GameManager.score instead)

# ❌ Tight Coupling
# In Ball.gd:
var brick_manager = load("res://scripts/systems/BrickManager.gd").new()  # ❌
```

---

## 📝 Code-Style & Best Practices

### GDScript

**Strikte Typing:**
```gdscript
# ✅ Gut: Explizite Types
var speed: float = 500.0
var hp: int = 3
var velocity: Vector2 = Vector2.ZERO

func add_score(points: int) -> void:
    score += points

func get_highscore(level: int) -> int:
    return highscores.get(str(level), 0)
```

**Dokumentation:**
```gdscript
## Brief description of the class
##
## Detailed explanation of what this class does,
## how it should be used, etc.
extends Node2D
class_name Ball

## Emitted when ball collides with a brick
signal collided_with_brick(brick: Node2D)

## Ball movement speed in pixels/second
@export var speed: float = 500.0
```

### Naming Conventions

- **Scenes**: PascalCase (`Ball.tscn`, `GameManager.gd`)
- **Funktionen**: snake_case (`add_score`, `load_level`)
- **Variablen**: snake_case (`current_level`, `ball_speed`)
- **Private Variablen**: `_snake_case` (`_velocity`, `_is_ready`)
- **Konstanten**: UPPER_SNAKE_CASE (`MAX_SPEED`, `SAVE_PATH`)
- **Signals**: snake_case (`score_changed`, `level_completed`)
- **Classes**: PascalCase (`BrickType`, `LevelData`)

### Datei-Struktur (GDScript)

```gdscript
# 1. extends (Base-Class)
extends Node2D

# 2. class_name (Optional)
class_name Ball

# 3. Signals
signal collided_with_brick(brick: Node2D)
signal out_of_bounds

# 4. Constants
const MAX_SPEED = 1000.0
const MIN_SPEED = 100.0

# 5. @export Variables (Inspector-visible)
@export var speed: float = 500.0
@export var color: Color = Color.WHITE

# 6. @onready Variables (Cached Node-Referenzen)
@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

# 7. Public Variables
var velocity: Vector2 = Vector2.ZERO
var is_active: bool = true

# 8. Private Variables
var _internal_state: int = 0

# 9. Lifecycle-Funktionen (in Reihenfolge)
func _ready():
    pass

func _process(delta):
    pass

func _physics_process(delta):
    pass

# 10. Public Functions
func shoot(angle: float) -> void:
    velocity = Vector2.from_angle(angle) * speed

func reset() -> void:
    velocity = Vector2.ZERO

# 11. Private Functions
func _calculate_bounce(normal: Vector2) -> Vector2:
    return velocity.bounce(normal)

# 12. Signal-Callbacks (Convention: _on_*)
func _on_area_entered(area: Area2D):
    pass
```

---

## 🧪 Testing-Richtlinien

### Test-Struktur (GUT Framework)
```
scenes/entities/Ball.tscn
scenes/entities/Ball.gd
tests/unit/test_ball.gd    # GUT Unit-Test
```

### Was wird getestet?
- ✅ Scene-Instanziierung
- ✅ Funktions-Logik (besonders in scripts/utils/)
- ✅ Signal-Emissionen
- ✅ Edge-Cases (z.B. Division durch Null)
- ❌ Implementation-Details

**Beispiel-Test:**
```gdscript
# tests/unit/test_ball.gd
extends GutTest

func test_ball_initialization():
    var ball = preload("res://scenes/entities/Ball.tscn").instantiate()
    assert_not_null(ball)
    assert_eq(ball.speed, 500.0)

func test_ball_bounce():
    var ball = Ball.new()
    ball.velocity = Vector2(100, -100)
    var normal = Vector2(0, 1)  # Boden-Normale
    var bounced = ball.velocity.bounce(normal)
    assert_eq(bounced.y, 100)  # Y invertiert
```

---

## 🚫 Anti-Patterns

### Zu vermeiden:

**1. God Nodes**
```gdscript
# ❌ 500 Zeilen Script mit allem
# Game.gd
extends Node2D

func _ready():
    # Ball-Spawning, Brick-Management, UI-Updates, Audio, Save/Load...
    # ALLES in einer Datei!

# ✅ Aufgeteilt in kleinere Bausteine
# Game.gd (nur Orchestration)
extends Node2D

@onready var launcher = $Launcher
@onready var brick_container = $BrickContainer
@onready var ball_container = $BallContainer

func _ready():
    launcher.shoot_requested.connect(_on_shoot_requested)
    _setup_bricks()

func _on_shoot_requested(angle: float):
    launcher.spawn_ball_sequence(50, angle)
```

**2. Hardcoded Node-Paths**
```gdscript
# ❌ Fragile, bricht bei Umbenennung
var score_label = get_node("/root/Main/UI/HUD/ScoreLabel")

# ✅ @onready mit relativem Pfad
@onready var score_label = $"../UI/HUD/ScoreLabel"

# ✅ Noch besser: @export mit Inspector-Zuweisung
@export var score_label: Label
```

**3. Mixed Concerns**
```gdscript
# ❌ UI und Business-Logic gemischt
# Ball.gd
extends CharacterBody2D

func _physics_process(delta):
    move_and_collide(velocity * delta)

    # ❌ Ball updated direkt UI
    var hud = get_node("/root/Game/UI/HUD")
    hud.update_ball_count(get_tree().get_nodes_in_group("balls").size())

# ✅ Getrennte Verantwortlichkeiten
# Ball.gd
extends CharacterBody2D
signal ball_destroyed

func _physics_process(delta):
    move_and_collide(velocity * delta)

func destroy():
    ball_destroyed.emit()
    queue_free()

# Game.gd (Orchestrator)
func _on_ball_destroyed():
    var ball_count = get_tree().get_nodes_in_group("balls").size()
    hud.update_ball_count(ball_count)
```

**4. Polling statt Signals**
```gdscript
# ❌ Polling (ineffizient)
func _process(delta):
    if some_condition_changed:
        notify_listeners()

# ✅ Signals (Event-driven)
signal condition_changed

func check_condition():
    if some_condition:
        condition_changed.emit()
```

---

## 🤖 Anweisungen für AI-Assistenten

### Workflow bei Anfragen

**1. Scope klären**
- Welche Scenes/Scripts sind betroffen?
- Gibt es Signal-Abhängigkeiten?
- Ist die Änderung isoliert möglich?

**2. Vor der Änderung fragen**
```
"Diese Änderung betrifft auch Scene X und Script Y.
Soll ich diese auch anpassen oder nur [Ursprungsdatei]?"
```

**3. Nach Modularer Struktur arbeiten**
- Neue Features → Neue Scenes/Scripts
- Bestehende Features → Minimale, fokussierte Änderungen
- Immer Isolation im Kopf behalten
- Signals für Kommunikation nutzen

**4. Dokumentation**
- Neue Scenes/Scripts brauchen DocComments (`##`)
- Komplexe Logik wird erklärt
- Signals sind dokumentiert mit Parametern

### Fragen, die du stellen solltest

- "Soll ich eine neue Scene erstellen oder die bestehende erweitern?"
- "Diese Änderung betrifft auch [Scene X]. Wie möchtest du vorgehen?"
- "Ich sehe, dass Signal-Pattern Y verwendet wird. Soll ich das beibehalten?"
- "Soll ich die neue Funktion in scripts/utils/ (pure function) oder als Autoload erstellen?"

---

## 🎮 Godot-Spezifische Best Practices

### Scene-Instanziierung

```gdscript
# ✅ Gut: preload für bekannte Pfade
const BALL_SCENE = preload("res://scenes/entities/Ball.tscn")

func spawn_ball():
    var ball = BALL_SCENE.instantiate()
    add_child(ball)

# ✅ Gut: load für dynamische Pfade
func load_level(level_num: int):
    var level_path = "res://scenes/levels/Level%02d.tscn" % level_num
    var level_scene = load(level_path)
    var level = level_scene.instantiate()
```

### @onready vs. _ready()

```gdscript
# ✅ Gut: @onready für Node-Referenzen
@onready var sprite = $Sprite2D
@onready var anim_player = $AnimationPlayer

# ✅ Gut: _ready() für Initialization-Logic
func _ready():
    sprite.modulate = color
    anim_player.play("idle")
```

### Signal-Connections

```gdscript
# ✅ Gut: Connect in _ready()
func _ready():
    button.pressed.connect(_on_button_pressed)
    # Oder mit lambda:
    button.pressed.connect(func(): print("Clicked!"))

# ✅ Alternativ: Via Inspector (für Editor-Setup)
# Dann automatischer Callback:
func _on_button_pressed():
    pass
```

### Resource-System

```gdscript
# Custom Resource definieren
# resources/brick_types/BrickType.gd
extends Resource
class_name BrickType

@export var hp: int = 1
@export var points: int = 100
@export var color: Color = Color.WHITE
@export var texture: Texture2D

# Resource verwenden
# Brick.gd
@export var brick_type: BrickType

func _ready():
    if brick_type:
        hp = brick_type.hp
        $Sprite2D.modulate = brick_type.color
```

---

## 📚 Zusätzliche Ressourcen

- Siehe `README.md` für Setup-Anleitung
- Siehe `ARCHITECTURE.md` für detaillierte System-Architektur
- Siehe `GODOT_PLAN.md` für vollständigen Tech-Stack-Plan
- Siehe `MILESTONES.md` für Entwicklungs-Roadmap
- Godot Docs: https://docs.godotengine.org/

---

## ✅ Checkliste für jeden Commit

- [ ] Nur angeforderte Dateien geändert
- [ ] Keine ungewollten Refactorings
- [ ] Types sind korrekt definiert (`: Type`)
- [ ] Signals sind dokumentiert
- [ ] Code folgt Naming-Conventions (snake_case für Funktionen/Variablen)
- [ ] Scene/Script ist isoliert/wiederverwendbar
- [ ] Keine direkten Node-Paths zwischen Features
- [ ] Kommunikation über Signals oder Autoload
- [ ] Maximale Dateigröße: 200-250 Zeilen

---

**Version:** 2.0 (Godot 4)
**Letzte Aktualisierung:** 2025-01-06
**Engine:** Godot 4.4+
