# Build Lab

A [Balatro](https://www.playbalatro.com/) mod: a native-styled **custom run builder** plus the
**Impossible** rarity, five deliberately broken-but-coherent Jokers obtainable only through the Build Lab.

## What you get

**Build Lab page** in the New Run flow (Play → deck → stake → **Build Lab** → Play):
- Five starting-Joker slots. Pick from every loaded Joker (vanilla and modded) in a searchable, paged grid
  with a rarity filter and real hover tooltips.
- Edition per slot: Base, Foil, Holographic, Polychrome, Negative, previewed live on the card.
- Advanced: starting Money, Hands, Discards, Hand Size, Joker Slots, Consumable Slots ("Auto" keeps the
  deck and stake effects).
- Seed via the normal seed toggle on the run-select bar.
- Presets: save, load, overwrite, delete. Stored in `presets.json` in the mod folder, so you can share
  the file. Two built-ins ship: **Facepocalypse** and **Baron Machine**. Presets that reference a Joker
  from a mod you don't have load with that slot empty and a warning, never a crash.

**Impossible rarity** (crimson badge, never rolls in shops unless you turn it on in the config):
- **The Fun Hoe**: scored face cards are harvested after scoring; gains X0.5 Mult per harvest. Harvested
  cards return to the deck if it is sold.
- **Bambino**: at end of round the Joker to its right becomes Negative; X1 Mult plus X0.5 per Negative Joker.
- **Jazzy Clown**: retrigger the leftmost scored card 3 times; +1 every 3rd hand; 1 in 4 chance of Zoomies
  (retrigger every scored card once).
- **The Understudy**: copies the Jokers directly left and right.
- **The Forger**: each hand, every unenhanced scored card gains a random enhancement and one scored card
  gains a Red Seal. Not copyable by Blueprint.

## Install

1. Install [Lovely](https://github.com/ethangreen-dev/lovely-injector) (copy `version.dll` next to
   `Balatro.exe`).
2. Install [Steamodded](https://github.com/Steamodded/smods) **26.829.0 or newer** into
   `%AppData%\Balatro\Mods\Steamodded` (download: https://download.smods.dev).
3. Drop this folder into `%AppData%\Balatro\Mods\BuildLab`.
4. Launch. Build Lab appears in the Mods menu; its Config tab has two toggles: allow Impossible Jokers in
   shops (0.1% weight) and hide the Build Lab page.

Note: with any mod page registered, Steamodded uses its own run-select screen (the vanilla New Run tab
toggle in Steamodded settings is ignored). That is by design of Steamodded.

## Development

- `python tools/luacheck.py .` syntax-checks every Lua file with the game's own LuaJIT DLL.
- `python tools/build_atlas.py` rebuilds `assets/1x|2x/Jokers_bl.png` from `joker-design-*.png`.
- Read `CLAUDE.md` and `docs/` before changing anything. Every game API used is logged in
  `docs/smods-notes.md` with its source location.

## License

GPL-3.0. See `LICENSE`. Patterns adapted from Steamodded, Cryptid, Galdur and Balatro-DeckCreator
(all GPL-3.0) are credited inline where used.
