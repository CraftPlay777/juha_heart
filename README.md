# juha_heart
Adds invisible lives (HP-based) shown as HUD text with a white background above the hearts bar. Invisible lives absorb damage before it reaches real HP, and persist across sessions.

## Command

```
/heart <hp> [player]
/heart quit <hp> [player]
```

## Usage
| Syntax | Effect |
|---|---|
| `/heart 7` | Sets your invisible HP to 7 |
| `/heart 3` | Replaces previous value — now 3 |
| `/heart quit 1` | Subtracts 1 from your invisible HP |
| `/heart 10 Pablito` | Sets Pablito's invisible HP to 10 |
| `/heart quit 5 Pablito` | Subtracts 5 from Pablito's invisible HP |

## Notes
- HP values are per half-heart (1 HP = ½ heart, 2 HP = 1 heart).
- Setting a new value always **replaces** the previous one.
- Invisible lives **absorb damage first** — real HP is only affected once invisible HP runs out.
- If damage exceeds remaining invisible HP, the leftover damage carries over to real HP normally.
- When invisible HP reaches 0, the HUD element disappears automatically.
- Invisible HP **persists across sessions** — rejoining restores the last saved value.
- Requires the `heart` privilege.
- Contains translations into 3 languages (es, en, fr)

## IMPORTANT
If the HUD doesn't look right, adjust this line in init.lua by approximately 8/10 lines.
```
local POS     = {x = 0.5, y = 1.0}
local OFF_BG  = {x = -230, y = -100} -- edit this
local OFF_TXT = {x = -229, y = -100} -- and this
local COLOR   = 0x111111
```

**Author:** Juha (CraftPlay777)  
**License:** MIT