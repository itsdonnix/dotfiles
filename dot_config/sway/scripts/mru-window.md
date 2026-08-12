# mru-window

Small V program for Sway MRU window switching.

## Commands

```sh
mru-window track
mru-window toggle
```

- `track`: watch window focus
- `toggle`: focus previous window on current workspace
- fallback: `focus next` when history missing/stale

## Flow

```text
                 Sway IPC
                    |
          +---------+---------+
          |                   |
       track                toggle
          |                   |
    focus events       workspace + tree
          |                   |
          +---- MRU state ----+
                    |
             focus previous
```

## State

```text
${XDG_RUNTIME_DIR:-/tmp}/sway-mru-<uid>/
├── workspace-<id>      two recent container IDs
├── track.lock          single tracker lock
├── mru-window.log
└── mru-window.log.old
```

First line in `workspace-<id>` = newest focus.

## Sway config

```text
exec_always --no-startup-id exec "$HOME/.config/sway/scripts/mru-window" track
bindsym $mod+Tab exec "$HOME/.config/sway/scripts/mru-window" toggle
```

`exec` removes the shell wrapper. Tracker runs directly under Sway.

## Build

```sh
v fmt -w scripts/mru-window.v
v vet scripts/mru-window.v
v -prod -o scripts/mru-window scripts/mru-window.v
chmod 755 scripts/mru-window
swaymsg reload
```

## Check

```sh
pgrep -af 'mru-window track'
tail -f "$XDG_RUNTIME_DIR/sway-mru-$UID/mru-window.log"
```

Expected: one tracker and `event=subscribed` in log.

## Troubleshooting

### No tracker

```sh
swaymsg reload
pgrep -af 'mru-window track'
```

### Toggle problem

```sh
"$HOME/.config/sway/scripts/mru-window" toggle
tail -n 50 "$XDG_RUNTIME_DIR/sway-mru-$UID/mru-window.log"
```

### Stale history

Safe to reset:

```sh
rm "$XDG_RUNTIME_DIR/sway-mru-$UID"/workspace-*
```

History rebuilds from focus events.

### Duplicate tracker

Extra tracker exits because of `track.lock`. `duplicate_tracker_rejected` is normal when testing duplicates.

### IPC reconnect loop

```sh
printf '%s\n' "$SWAYSOCK"
swaymsg -t get_version
```

Tracker reconnects automatically with capped backoff.
