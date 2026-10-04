# Messages extended

Convenient controls for Crusader Kings III's bottom-right messages, using the current vanilla icons and styling.

## Features

- Clear all messages with the compact broom button or **Ctrl+right-click**.
- Hide the feed completely or automatically while a right-side window is open.
- One shared button opens settings or, when messages are hidden, becomes a restore arrow. Hiding preserves messages.
- Localized in all nine game languages.

## Installation

- **From this project:** run `.\deploy_mod.ps1` in PowerShell, then enable **Messages extended** in your CK3 launcher playset.
- **Manual:** copy `mod/` as `MessagesExtended/` into `Documents/Paradox Interactive/Crusader Kings III/mod/`. Copy the project's root `descriptor.mod` beside that folder as `MessagesExtended.mod`, then enable it in your playset.
- **Steam Workshop, when published:** subscribe and enable the mod in your playset.
- **Uninstall the local copy:** run `.\deploy_mod.ps1 -Remove`.

## How to Use

| Control | Action | From |
| --- | --- | --- |
| **Ctrl+right-click** a message | Clear all messages | Mod |
| **Ctrl+Shift+M** | Toggle complete hiding of the feed | Mod |
| **Broom button** beside the list | Clear all messages | Mod |
| **Ctrl+Shift+F** | Clear all messages | Base game |
| **M** | Open/close the game's Message Settings window | Base game |
| **Alt+F** in the Message Log | Toggle compact log layout | Base game |
| **Right-click a message header** | Dismiss that message | Base game |
| **Right-click a message's dismiss button** | Clear all messages | Base game |

The button below the broom opens the mod's display settings; **M** opens the game's separate Message Settings window. The **Show Messages** decision also restores a hidden feed.

## Compatibility

- **Game:** CK3 **1.20.***; based on **1.20.0.3**.
- **Saves:** supports existing saves; display preferences follow your player character changes.
- **Conflicts:** other mods replacing the message feed, including Clear Notifications. Enable only one.
- **Scope:** bottom-right messages only; events and top-screen alerts are unaffected.

## Support

For bug reports, include your CK3 version, active mods, and a screenshot or `logs/error.log`.
