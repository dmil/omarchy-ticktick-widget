# omarchy-ticktick-widget

An [eww](https://github.com/elkowar/eww) desktop widget for [Omarchy](https://omarchy.org/) that shows your TickTick "Today" tasks as a background desktop widget.

![Widget shows today's date, tasks grouped by list, with priority dots and click-to-open](.github/preview.png)

## Features

- Tasks grouped by TickTick list, with a header per list
- Priority shown as colored emoji dots (🔴 high, 🟡 medium, 🔵 low)
- Click any task to open it directly in the TickTick web app
- Click the header to collapse/expand the widget
- Sits in the desktop background — doesn't overlap windows
- Refreshes every 5 minutes, with a 5-minute file cache
- Survives theme and wallpaper switches via Omarchy hooks + Hyprland autostart

## How it works

```
ticktick-today (Python script)
  └── Reads token from ~/.config/ticktick-widget/token.json
  └── Calls TickTick Open API to fetch today's tasks
  └── Groups tasks by project, sorts by priority
  └── Outputs JSON → eww polls this every 5 minutes

eww (widget system)
  └── Renders the JSON as a GTK layer shell window
  └── Sits at stacking "bg" — behind all windows
  └── onclick opens task URL in browser via xdg-open
  └── onhover/onhoverlost drives hover highlight via defvar
```

## Requirements

- [eww](https://github.com/elkowar/eww) — installed from AUR
- Python 3 with `requests` (`python-requests` package)
- A TickTick API access token (see below)

## Getting a TickTick API token

1. Go to https://developer.ticktick.com/manage
2. Click your app to open its settings
3. Copy the access token from the token field

## Installation

```bash
git clone https://github.com/dmil/omarchy-ticktick-widget
cd omarchy-ticktick-widget
./install.sh
```

The installer will:
- Install `eww` from the AUR (if not already installed)
- Install `python-requests` if needed
- Copy scripts to `~/.local/bin/`
- Copy eww config to `~/.config/eww/`
- Prompt you to save your API token
- Optionally add the widget to Hyprland autostart

## Manual setup

```bash
# Save your token
ticktick-auth

# Launch the widget
eww daemon && eww open ticktick
```

## File layout

```
omarchy-ticktick-widget/
├── install.sh                  # One-shot installer
├── scripts/
│   ├── ticktick-auth           # Saves your API token to ~/.config/ticktick-widget/token.json
│   └── ticktick-today          # Fetches today's tasks as grouped JSON for eww
└── eww/
    ├── eww.yuck                # Widget layout (yuck DSL)
    └── eww.scss                # Styling (Flexoki Light theme)
```

### Token storage

Your API token is stored locally at `~/.config/ticktick-widget/token.json` and is never committed to this repo.

## Usage

| Action | Result |
|--------|--------|
| Click header | Collapse / expand task list |
| Click a task | Open that task in TickTick web app |
| Hover a task | Highlight row |

```bash
eww open ticktick      # Show widget
eww close ticktick     # Hide widget
eww reload             # Force refresh tasks now
eww kill               # Kill eww daemon
```

## Omarchy integration

The installer creates `~/.config/omarchy/hooks/theme-set` to restart the widget after theme changes, picking up the new background color. The Hyprland autostart uses `exec` (not `exec-once`) so the widget also comes back after wallpaper switches and config reloads.

## Re-authorizing

If your token expires:

```bash
ticktick-auth
# Paste your new access token when prompted
```
