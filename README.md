# 🎮 Multi-Ball Breaker

Ein modernes Brick-Breaker-Spiel mit 50 Bällen, entwickelt mit Godot 4.4.

![Godot](https://img.shields.io/badge/Godot-4.4%2B-blue?logo=godot-engine)
![Status](https://img.shields.io/badge/Status-In%20Development-yellow)

---

## 🎯 Spielkonzept

**Multi-Ball Breaker** ist eine frische Adaption des klassischen Brick-Breaker-Spiels:

- **50 Bälle** werden in schneller Sequenz abgeschossen
- **Spiegelreflexion** ohne komplexe Physik-Engine
- **Statische Abschussrampe** (kein beweglicher Paddle)
- **Score-System**: Weniger Versuche = besser (wie Golf)
- **Ziel**: Alle Bricks mit möglichst wenig Versuchen zerstören

---

## ✨ Features

### Phase 1 (MVP) - ✅ In Entwicklung
- ✅ 50-Ball-Sequencing mit präzisem Timing
- ✅ Spiegelreflexions-Physik
- ✅ Versuchs-Zähler (Golf-Par-System)
- ✅ 5 handgefertigte Levels
- ✅ Lokales Highscore-System
- ✅ Basic UI (HUD, Menüs)

### Phase 2 (Planned)
- 🔄 Brick-Typen (1-3 HP)
- 🎵 Sound-Effekte & Musik
- 🎆 Partikel-Effekte
- 🔄 Undo-System
- 🎯 Trajectory-Preview

### Phase 3 (Future)
- 🌐 Online-Leaderboard
- 📅 Daily-Challenge
- 🎨 Level-Sharing

---

## 🚀 Setup

### Requirements

- **Godot 4.4+** (Forward+ Renderer)
- Windows, macOS oder Linux

### Installation

1. **Godot installieren:**
   ```
   https://godotengine.org/download
   ```

2. **Projekt klonen:**
   ```bash
   git clone https://github.com/yourusername/multiballbraker.git
   cd multiballbraker
   ```

3. **Projekt in Godot öffnen:**
   - Godot starten
   - "Import" → `project.godot` auswählen
   - "Import & Edit"

4. **Spiel starten:**
   - **F5** drücken oder Play-Button klicken

---

## 🎮 Controls

| Aktion | Input |
|--------|-------|
| **Zielen** | Maus bewegen |
| **Schießen** | Linksklick |
| **Restart** | R |
| **Undo** | Ctrl+Z (1x pro Level) |
| **Pause** | Escape |

---

## 📂 Projekt-Struktur

```
multiballbraker/
├── scenes/              # Godot-Scenes (.tscn + .gd)
│   ├── main/           # Root-Scene
│   ├── game/           # Game-Scene
│   ├── entities/       # Ball, Brick, Launcher
│   ├── ui/             # HUD, Menüs
│   └── levels/         # Level-Layouts
│
├── scripts/            # Pure GDScript
│   ├── autoload/       # Singletons (GameManager, AudioManager, etc.)
│   ├── systems/        # Wiederverwendbare Systeme
│   └── utils/          # Helper-Funktionen
│
├── resources/          # Custom Resources (.tres)
│   ├── level_data/
│   └── brick_types/
│
├── assets/             # Art & Audio
│   ├── sprites/
│   ├── sounds/
│   ├── fonts/
│   └── particles/
│
└── tests/              # Unit-Tests (GUT)
```

---

## 🛠️ Development

### Architektur-Prinzipien

Dieses Projekt folgt strengen Architektur-Richtlinien:

- **Modularer "Lego-Baustein" Ansatz** - Jede Scene/Script ist isoliert
- **Single Responsibility** - Max. 200-250 Zeilen pro Datei
- **Signal-basierte Kommunikation** - Loose Coupling
- **Autoload-Pattern** - Globaler State via Singletons

Siehe [DEVELOPMENT.md](DEVELOPMENT.md) für vollständige Richtlinien.

### Dokumentation

- **[DEVELOPMENT.md](DEVELOPMENT.md)** - Architektur-Richtlinien & Code-Style
- **[GODOT_PLAN.md](GODOT_PLAN.md)** - Vollständiger Tech-Stack-Plan
- **[MILESTONES.md](MILESTONES.md)** - Entwicklungs-Roadmap
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Detaillierte System-Architektur

### Contribution

1. Fork das Repository
2. Feature-Branch erstellen: `git checkout -b feature/AmazingFeature`
3. Änderungen commiten: `git commit -m 'Add AmazingFeature'`
4. Branch pushen: `git push origin feature/AmazingFeature`
5. Pull-Request öffnen

**Wichtig:** Bitte [DEVELOPMENT.md](DEVELOPMENT.md) lesen bevor du beiträgst!

---

## 🏗️ Build

### Windows

```
Project → Export → Windows Desktop
```

### Web (HTML5)

```
Project → Export → Web
```

Deployment via itch.io oder GitHub Pages.

### Linux

```
Project → Export → Linux/X11
```

---

## 🧪 Testing

Unit-Tests mit [GUT (Godot Unit Testing)](https://github.com/bitwes/Gut):

```bash
# GUT über Asset-Library installieren
# Dann:
Tools → Gut → Run All Tests
```

---

## 📜 Lizenz

MIT License - siehe [LICENSE](LICENSE)

---

## 🙏 Credits

- **Engine:** [Godot 4.4](https://godotengine.org/)
- **Entwicklung:** [Dein Name]
- **Inspiration:** Klassische Brick-Breaker-Spiele

---

## 📞 Kontakt

Fragen? Feedback? Bugs?

- **Issues:** [GitHub Issues](https://github.com/yourusername/multiballbraker/issues)
- **Email:** your.email@example.com

---

**Happy Breaking!** 🎮🧱
