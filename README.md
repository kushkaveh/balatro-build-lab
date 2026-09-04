<img width="800" height="350" alt="Buildlab" src="https://github.com/user-attachments/assets/88e01fb9-d106-4ef7-b2d9-99d9cc71a547" />

## Build Lab

A mod for [Balatro](https://www.playbalatro.com/) that adds two things:

1. **The Build Lab**, a page in the New Run screen where you choose your starting Jokers (with editions), your
   starting money, hands, discards and slots, and save the whole thing as a preset.
2. **The Impossible rarity**: ten deliberately broken-but-coherent Jokers you can only get through the Build Lab.

Everything is drawn with the game's own UI, so it looks and feels like Balatro.

---

## Install (step by step, no experience needed)

Balatro mods need two small helper tools first. The whole process takes about five minutes.

### 1. Find your Balatro folder

- In Steam, right-click **Balatro** → **Manage** → **Browse local files**. A folder opens that contains
  `Balatro.exe`. Keep this window open.

### 2. Install Lovely (the mod loader's engine)

1. Download `lovely-x86_64-pc-windows-msvc.zip` from the
   [Lovely releases page](https://github.com/ethangreen-dev/lovely-injector/releases/latest).
2. Open the zip. Copy the file **`version.dll`** into the Balatro folder from step 1, next to `Balatro.exe`.

That's all Lovely needs. To uninstall it later, delete `version.dll`.

### 3. Install Steamodded (the mod loader)

1. Download the Steamodded zip from **https://download.smods.dev** (this always gives you the current stable
   version; Build Lab needs 26.829.0 or newer).
2. Press `Win + R`, type `%AppData%\Balatro` and press Enter. This is Balatro's save folder.
3. Inside it, create a folder called **`Mods`** if it does not exist yet.
4. Extract the Steamodded zip into `Mods`. You should end up with a folder like `Mods\smods-stable` (any
   name is fine) that directly contains `version.lua`, `manifest.json` and a `src` folder.

### 4. Install Build Lab

1. On this page, click the green **Code** button → **Download ZIP**.
2. Extract it into the same `Mods` folder. You should end up with `Mods\balatro-build-lab-main` (or any
   name you like) that directly contains `buildlab.json` and `main.lua`.

Your `Mods` folder now looks like this:

```
%AppData%\Balatro\Mods\
├── smods-stable\        (Steamodded)
└── balatro-build-lab\   (this mod)
```

### 5. Launch and check

Start Balatro normally. A black text window opens next to the game; that is Lovely's console and it is
normal. On the main menu click **Mods**: you should see **Steamodded** and **Build Lab**.

If Build Lab is missing, see [Troubleshooting](#troubleshooting).

---

## How to use the Build Lab

1. Main menu → **Play** → **New Run**.
2. Pick your **deck**, then your **stake**, as usual.
3. The third page is **Build Lab**:
   - **Pick** on any slot opens a grid of every Joker in your game (vanilla and modded). Type to search, use
     the rarity filter, hover a card for its full description, click it to choose it.
   - Under each chosen Joker, cycle its **edition**: Base, Foil, Holographic, Polychrome, Negative. The card
     preview updates instantly.
   - Setting a Joker to **Negative** opens an extra slot (Negative Jokers do not take a slot in Balatro).
     Arrows appear to page through your slots; up to 20 Jokers are possible.
   - **Advanced** opens the run settings: Money, Hands, Discards, Hand Size, Joker Slots, Consumable Slots.
     "Auto" means "whatever the deck and stake would normally give".
   - **Presets** lets you save the current build under a name, load one, overwrite or delete it. Two builds
     come with the mod: **Facepocalypse** and **Baron Machine**. Loading a preset also switches the deck and
     stake for you.
   - Want a fixed seed? Use the **Enable Seed** toggle in the bar below, exactly as in a normal run.
4. Press **Play**. The run starts with everything you chose. It saves and continues like any other run.

Presets are stored in `presets.json` inside the mod folder. Share that file with a friend and they get your
builds; a preset that uses a Joker from a mod they do not have simply loads with that slot empty.

### Mod settings

Main menu → **Mods** → **Build Lab** → **Config**:

- **Impossible Jokers in shops**: off by default. Turn it on to let them appear very rarely (about 0.1%).
- **Hide the Build Lab page**: keeps the Impossible Jokers but removes the builder page from New Run.

---

## The Impossible Jokers

All ten cost $50, never appear in shops unless you enable it, and are designed to be absurd but coherent.

| Joker | What it does |
|---|---|
| **The Fun Hoe** | Scored face cards are harvested after scoring; gains X0.5 Mult per harvest. Sell it and the harvested cards return to your deck. |
| **Bambino** | At end of round the Joker to its right becomes Negative. X1 Mult plus X0.5 per Negative Joker. |
| **Jazzy Clown** | Retriggers the leftmost scored card 3 times, +1 every 3rd hand. 1 in 4 chance of Zoomies: retrigger every scored card once. |
| **The Understudy** | Copies the Jokers directly left and right of it. |
| **The Forger** | Each hand, every unenhanced scored card gains a random enhancement and one scored card gains a Red Seal. Not copyable. |
| **Saving Face** | Whenever a face card is destroyed, three random-suit Aces with random enhancements join your deck. |
| **Velvet Rope** | Each Blind you select lets in a random Rare Joker with Negative edition (stops at 30 Jokers). |
| **The Smelter** | Scored cards lose their enhancement; +15 Mult per melt, forever. |
| **The Dude** | At end of round, X0.3 Mult for each unused hand and discard. The Dude abides. |
| **The Singularity** | X0.4 Mult every time a Joker or consumable is sold or destroyed (using a consumable does not count). |

They work with Blueprint, Brainstorm and Showman. Copies deliver the current bonus; the counters only grow on
the real card.

---

## Troubleshooting

- **No black console window appears**: `version.dll` is not next to `Balatro.exe`. Repeat step 2.
- **Mods button missing**: Steamodded is not in `%AppData%\Balatro\Mods`, or its folder is nested one level
  too deep (open it: you must see `version.lua` directly inside).
- **Build Lab missing from the Mods list**: same check for the Build Lab folder (`buildlab.json` must be
  directly inside it). Also make sure Steamodded is 26.829.0 or newer (shown in the Mods list).
- **The New Run screen looks different from vanilla**: that is Steamodded's own run-select screen, which it
  uses whenever a mod adds a page. This is expected.
- **Something crashed**: the log is in `%AppData%\Balatro\Mods\lovely\log\`. Open an issue on this repository
  and attach the newest log file.
- **Uninstall**: delete the Build Lab folder from `Mods`. Your saves are untouched.

---

## For developers

- Requirements: Steamodded 26.829.0+, Lovely 0.9.0+, Balatro 1.0.1o.
- `python tools/luacheck.py .` syntax-checks every Lua file with the game's own LuaJIT DLL (set
  `BALATRO_DIR` to your Balatro folder).
- `python tools/build_atlas.py` rebuilds `assets/1x|2x/Jokers_bl.png` from the `joker-design-*.png` sources.
- Read `CLAUDE.md`, `docs/architecture.md` and `docs/conventions.md` before changing anything. Every game API
  used is logged with its source location in `docs/smods-notes.md`. No base-game files are patched.

## License

GPL-3.0. See `LICENSE`. Patterns adapted from Steamodded, Cryptid, Galdur and Balatro-DeckCreator
(all GPL-3.0) are credited inline where used.
