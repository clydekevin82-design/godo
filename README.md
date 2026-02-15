# HyperSnow - Weather Control Mystery

A narrative-driven atmospheric horror/mystery game set in a remote snow wasteland.

## Core Premise

You are a technician assigned to maintain a remote weather-control array.

The storm started after a failed system test.

You've been sent to: **"Restore the array and stabilize the environment."**

But the truth?
- You were the one who caused it.
- The system isn't broken.
- It's protecting something.

## Game Structure

### 🗼 The Four Towers

Each tower changes the world and reveals more of the truth:

#### Tower 1 — Power Reboot
- Restores power to the array
- Lightning becomes **much more frequent**
- You start seeing distant silhouettes during flashes
- Objective updates to Tower 2

#### Tower 2 — Signal Calibration
- Storm quiets briefly
- You hear a voice in the static
- **It sounds like you**
- Messages from your past self warn you
- Objective updates to Tower 3

#### Tower 3 — Climate Control
- Snow stops for a moment
- You see how small the world actually is
- Revealing the containment field boundaries
- You learn this wasn't weather research
- Objective updates to Tower 4

#### Tower 4 — Containment Lock
- The truth is revealed
- This was a **containment facility**
- You didn't break it — you **activated** it
- The storm is a barrier
- Objective changes to "Survive."
- Lightning starts **hunting you**

## 🎮 Actual Gameplay Loop

```
Walk → Observe lightning → Find tower → Solve puzzle → Story beat → Storm intensifies → Audio distortion increases → Repeat
```

### Interactive Puzzles

Each tower requires solving a unique mechanical puzzle:

#### Tower 1 — Fuse Replacement ⚡
- **Mechanic**: Click 4 fuses in the correct sequence
- **Challenge**: Wrong order resets the puzzle
- **Correct sequence**: Fuse 1 → Fuse 3 → Fuse 2 → Fuse 4
- **Narrative**: "Power systems coming online..."

#### Tower 2 — Signal Dish Alignment 📡
- **Mechanic**: Rotate the satellite dish to align with the signal
- **Challenge**: Must reach 95%+ signal strength
- **Controls**: Left/Right rotation buttons (15° increments)
- **Narrative**: "Signal locked... but it's YOUR voice..."

#### Tower 3 — Frequency Calibration 📻
- **Mechanic**: Slide the frequency dial to match the target
- **Challenge**: Must get within 2 MHz of target frequency
- **Target**: Random between 30-70 MHz
- **Narrative**: "Climate stabilization... or containment?"

#### Tower 4 — Power Routing 🔌
- **Mechanic**: Connect 9 power nodes in correct sequence
- **Challenge**: Wrong node resets entire puzzle
- **Sequence**: 0 → 3 → 6 → 7 → 4 → 1 → 2 → 5 → 8
- **Narrative**: "The truth about containment..."

## Mechanics

### ⚡ Dynamic Lightning System
- Lightning flashes briefly reveal hidden structures
- A massive structure buried in the snow becomes visible during strikes
- **Late game**: Lightning targets the player's position
- Acts as both environmental storytelling and a threat

### 🌨️ Weather Progression
- Storm intensity changes based on tower activation
- Fog density shifts to reveal/obscure the truth
- Fog density shifts to reveal/obscure the truth
- Snow particles stop temporarily during Tower 3

### 🔊 Audio Distortion
- Progressively increases with each tower activation
- **15% distortion** after Tower 1 (subtle static)
- **35% distortion** after Tower 2 (voice messages become clearer)
- **Brief clarity** during Tower 3 (then returns worse)
- **85% distortion** after Tower 4 (warning tones, heavy interference)
- Creates psychological unease as the truth is revealed

### 🏔️ Environmental Detail
- **Snow Dunes**: 6 procedurally-scaled mounds creating rolling terrain
- **Rock Formations**: 8 scattered rocks of varying sizes (1.2m - 3.5m)
- **Subdivided Ground**: 64x64 mesh for detail and particle collision
- **Procedural Snow Material**: 
  - Cellular noise for surface variation
  - Normal mapping (8.0 bump strength)
  - Subsurface scattering for realistic snow appearance
  - Roughness texture for non-uniform reflectivity
- **Enhanced particle count**: 15,000 snowflakes (up from 12,000)

### 📡 Narrative Delivery
- Story beats appear as on-screen text panels
- Voice-like messages from your past self
- Environmental clues during lightning strikes
- Objective tracker in top-left corner

## Controls

- **WASD** - Move
- **Mouse** - Look around
- **Shift** - Sprint
- **Space** - Jump
- **E** - Activate towers (when near)
- **ESC** - Release mouse

## Technical Features

- Volumetric fog and clouds
- Procedural snow surface with subsurface scattering
- GPU particle systems (12,000 snowflakes)
- Dynamic lighting that responds to game state
- Screen-space effects (SSAO, SSIL, SSR)
- ACES tonemapping for realistic atmosphere

## File Structure

```
scripts/
├── first_person_controller.gd  # Player movement
├── game_manager.gd             # Core game state and progression
├── tower.gd                    # Tower interaction logic
├── weather_controller.gd       # Dynamic weather and lightning
└── ui_manager.gd               # Story beats and objectives

scenes/
└── Main.tscn                   # Complete game scene
```

## Development Notes

### Adding Thunder Sounds
To add thunder audio:
1. Add an `AudioStreamPlayer` node to the scene
2. In `weather_controller.gd`, update `_play_thunder()` to trigger the sound

### Extending the Narrative
Story beats are defined in `game_manager.gd`:
- Edit the `_tower_X_` functions to change dialogue
- Adjust timing with `await get_tree().create_timer()` calls
- Add new `show_story_beat()` calls anywhere

### Adjusting Difficulty
In `weather_controller.gd`:
- Modify lightning strike proximity in `_get_strike_position()`
- Change frequency multipliers in `game_manager.gd`'s `get_lightning_frequency()`

## Story Arc Summary

1. **Setup**: Routine maintenance mission
2. **Rising Action**: Each tower reveals uncomfortable truths
3. **Revelation**: This is a containment facility
4. **Climax**: You activated it, not broke it
5. **Resolution**: Survive what you've unleashed

---

*The storm isn't a malfunction. It's a barrier. And you just opened it.*
