# Roblox Black Hole

A high-intensity gravity system that pulls, consumes, and grows.

## Features
* **Dynamic Pull:** Realistic gravitational force based on distance.
* **Auto-Growth:** The black hole expands as time passes.
* **Player Lethality:** Automatically detects and kills players who enter the center.
* **Performance Ready:** Skips anchored parts.

## Setup
1. Create a **Part** in your Workspace.
2. Name it `BlackHole`.
3. Insert a **Server Script** into `ServerScriptService`.
4. Paste the code from `BlackHoleGravity.lua` into that script.

## Configuration
Adjust the behavior at the top of the script:
* `GRAVITY_STRENGTH`: Speed of the pull.
* `GROWTH_RATE`: How fast it expands.
* `MAX_SIZE`: The size limit for the part.
