# Darwin Home Desktop

This directory contains macOS-specific Home Manager modules. The desktop flow keeps the existing compact AeroSpace workspace model and does not expand workspace labels in SketchyBar.

## Workspace Model

- `T`: terminal and development tools
- `M`: music
- `B`: browsers
- `N`: notes
- `D`: Finder and document browsing
- `3`: chat and messaging
- `V`: virtual machines
- `I`: reverse engineering and IDA
- `X`: astrology and experiments
- `W`: work documents
- `P`: Photoshop and image tools

## Node Mode

Use AeroSpace service mode to start the node desktop mode:

```text
alt-shift-; n
```

The `desktop-mode node` command opens Obsidian and NetEase Music if they are not already running. It does not move windows directly; existing AeroSpace `on-window-detected` rules continue to route Obsidian to `N` and NetEase Music to `M`.
