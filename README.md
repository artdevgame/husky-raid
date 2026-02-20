# Husky Raid - Godot 4 CTF Game

A fast-paced 3D Capture the Flag game inspired by Halo Infinite's Husky Raid mode, built with Godot 4.

## Features

- **8-Player Multiplayer** - 4v4 Red vs Blue teams
- **Capture the Flag** - Grab the enemy flag, return it to your base to score
- **First to 3 Wins** - Matches end at 3 captures or when the 8-minute timer expires
- **6 Weapons** - Assault Rifle, Pistol, Shotgun, Sniper, Rocket Launcher, Energy Sword
- **Halo-Style Movement** - Sprint, slide, jump, thrust
- **Shield System** - Shields absorb damage before health

## Controls

| Action | Key |
|--------|-----|
| Move | WASD |
| Jump | Space |
| Sprint | Shift |
| Crouch/Slide | Ctrl |
| Thrust | E |
| Fire | Left Mouse |
| Aim Down Sights | Right Mouse |
| Melee | V |
| Grenade | G |
| Reload | R |
| Pause | Esc |

## How to Play

### Hosting a Game
1. Run the game
2. Click "HOST GAME"
3. Share the game code with friends
4. Click "START GAME" when ready

### Joining a Game
1. Run the game
2. Click "JOIN GAME"
3. Enter the host's IP address
4. Click "CONNECT"

### CTF Rules
- Touch the enemy flag at their base to pick it up
- Return to your own base with the enemy flag to score
- If you die while carrying the flag, it drops
- Touch your dropped flag to return it instantly
- Stand near your flag at base to return it (2.5 second timer)
- First team to 3 captures wins!

## Project Structure

```
husky-raid/
├── project.godot          # Godot project file
├── scenes/               # Game scenes
│   ├── main_menu.tscn    # Main menu
│   ├── lobby.tscn        # Pre-game lobby
│   ├── game.tscn        # Main game
│   ├── arena.tscn       # CTF arena
│   ├── player.tscn      # Player character
│   └── ui/              # UI elements
├── scripts/              # GDScript code
│   ├── player/          # Player controller
│   ├── weapons/        # Weapon systems
│   ├── ctf/            # CTF logic
│   ├── networking/     # Multiplayer
│   └── ui/             # Menu scripts
└── assets/              # Models, audio, textures
```

## Requirements

- Godot 4.2+
- PC (Windows/Mac/Linux)

## Adding Audio

Place OGG audio files in `assets/audio/sfx/`:
- footstep.ogg, jump.ogg, land.ogg
- fire_ar.ogg, fire_pistol.ogg, etc.
- flag_pickup.ogg, flag_capture.ogg

## Development

The game uses:
- P2P networking (ENet)
- CharacterBody3D for player movement
- Area3D for flag/base detection
- CanvasLayer for HUD

## Credits

Built with Godot Engine 4.x

## Generated Assets

The following assets have been generated with Meshy.ai:

| Status | Asset |
|--------|-------|
| ✅ Done | player_red.glb |
| ✅ Done | assault_rifle.glb |
| ⏳ Pending | player_blue, pistol, shotgun, sniper, rocket_launcher, energy_sword, flag_red, flag_blue |

### Generating More Assets

Run the generator script to create more assets:

```bash
source .venv/bin/activate
python3 generate_more.py
```

This will generate the remaining weapons and flags using Meshy.ai API.
