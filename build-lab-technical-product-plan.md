# Build Lab — Technical Product Plan
### A Custom Run Builder + "Impossible" rarity mod for Balatro
Research date: September 2026 · Target stack: Lovely + Steamodded (SMODS 1.0 beta line) · Dev workflow: Claude Code

---

## 1. Executive recommendation

**Build a thin, standalone SMODS mod (GPL-3.0). Do not fork anything. Reuse patterns — and, where useful, GPL code — from Balatro-DeckCreator, Cryptid, and Galdur.**

Why:

- **SMODS already provides ~80% of the hard machinery.** Custom rarities (`SMODS.Rarity`), custom Jokers (`SMODS.Joker`), spawning any Joker with any edition (`SMODS.add_card{ key=..., edition=... }`), atlases, localization, config persistence, and UI helpers are all first-class APIs. The genuinely custom work is one screen (the Build Lab UI) and one injection point (run start).
- **The obvious fork candidates are poor bases.** Balatro-DeckCreator covers most of the feature list on paper but predates the SMODS 1.0 rework, carries Balamod-era compatibility code, and has documented GUI crashes on current versions. ZokersModMenu covers starting Jokers + editions but is a cheat-menu UX (the opposite of "native-feeling"), and has no clear open-source license — so its code can't be safely reused, only its ideas.
- **SMODS is absorbing the run-setup surface.** The SMODS roadmap explicitly includes "Run Select Pages" — an improved incorporation of the Galdur mod's API for adding pages to the run-setup flow. A thin mod that adds one page/tab to run setup rides that wave; a fork of a 2024-era mega-mod fights it.
- **GPL keeps every door open.** SMODS, DeckCreator, and Cryptid are all GPL. Licensing Build Lab as GPL-3.0 lets you legally lift specific implementation snippets (e.g., DeckCreator's start-run injection, Cryptid's above-Legendary rarity setup) with attribution, without inheriting their architectures.

One-line architecture: **a native-styled "Build Lab" page in the run-setup flow → writes a plain Lua/JSON "run config" → a small hook applies it when the run starts → plus a self-contained content pack (1 rarity + 5 Jokers) that works even if the Builder UI is disabled.**

---

## 2. Ecosystem research (what exists today)

### The stack
- **Lovely** (`ethangreen-dev/lovely-injector`) is a runtime Lua injector: a `version.dll` (or dylib) placed next to `Balatro.exe` that patches the game's Lua **in memory at load time**. Nothing on disk is ever modified; deleting the DLL restores vanilla. Lovely also gives every mod a declarative patch format (`lovely.toml`) for targeted source patches when no hook exists.
- **Steamodded / SMODS** (`Steamodded/smods`, GPL) is the mod loader built on top of Lovely. It scans `%AppData%/Balatro/Mods/`, loads mods with metadata (`.json` manifest: id, prefix, dependencies, version constraints), and exposes the API surface: `SMODS.Joker`, `SMODS.Rarity`, `SMODS.Edition`, `SMODS.Atlas`, `SMODS.Sticker`, `SMODS.Challenge`, `SMODS.Keybind`, localization, calculate-function event system ("Better Calc"), object weights, and utility functions like `SMODS.create_card` / `SMODS.add_card`.
- **Docs moved:** the canonical documentation is now **https://docs.smods.dev** (the GitHub wiki redirects there). The 1.0 beta line (e.g. `1.0.0-beta-1814a`, mid-2026) is the current target; "Better Calc" (post Jan-2025) broke many old mods, which is exactly why forking a pre-1.0 mod is risky.
- Balatro itself is LÖVE/Lua; the full game source is readable by extracting `Balatro.exe` with 7-zip. This matters enormously for the vibe-coding workflow (§15): the agent should read real game source, not guess.

### Key APIs confirmed for our features
- **Spawn a specific Joker with a specific edition:** `SMODS.add_card{ set = 'Joker', key = 'j_blueprint', edition = 'e_negative', area = G.jokers }` — `key`, `edition`, `enhancement`, `seal`, `rarity`, `no_edition`, `skip_materialize` are all supported arguments. This single function is the heart of the run builder.
- **Custom rarity:** `SMODS.Rarity{ key = 'impossible', ... }` with badge colour, pool weight (can be 0 = never rolls naturally), and localization. Cryptid proves the "above Legendary, not in shop, summoned by a special mechanic" pattern works in production (its **Exotic** rarity).
- **Custom Jokers:** `SMODS.Joker` with `config.extra` state, `calculate(self, card, context)` event hooks (Better Calc contexts: `joker_main`, `individual`, `repetition`, `end_of_round`, `destroying_card`, etc.), `loc_vars` for dynamic tooltips, `blueprint_compat`, `eternal_compat`, `in_pool`.
- **Enumerate all Jokers for the picker:** iterate `G.P_CENTER_POOLS['Joker']` at menu time — this includes every loaded modded Joker automatically, each with `key`, `name`, localized text, rarity, and sprite. Rendering real `Card` objects in a menu `CardArea` gives authentic art + hover tooltips for free (this is exactly how the game's own Collection screen works — reuse that pattern).
- **Native UI:** Balatro's whole UI is Lua (`UIBox`/`UIElement` trees built from `{n = G.UIT.C, ...}` nodes; helpers like `create_option_cycle`, `UIBox_button`, `create_text_input`, `simple_text_container` in `functions/UI_definitions.lua`). SMODS documents this ("UI Structure" guide) and every well-made mod builds screens this way — that's how you get native panels, buttons, sounds, and hover states without imitating them.
- **Persistence:** SMODS gives each mod a config table persisted across restarts (`SMODS.current_mod.config` + config file); larger data can be written to the mod's folder via LÖVE's filesystem, the pattern DeckCreator uses for its shareable `CustomDecks.txt`.
- **Run-start control:** Balatro's own **Challenge system** already supports starting Jokers (with editions), custom money/hands/discards/hand size, banned items, and custom decks — `SMODS.Challenge` wraps it. Vanilla `G.FUNCS.start_run` / `Game:start_run(args)` accepts a challenge table. The cleanest injection is therefore: *translate the Build Lab config into a challenge-shaped ruleset* (or apply a small post-start hook for things challenges can't express, like per-slot stickers).

---

## 3. Existing-mod comparison

| Project | What it does | Overlap with us | License | Activity / SMODS-1.0 status | Verdict |
|---|---|---|---|---|---|
| **Steamodded (SMODS)** | Mod loader + full content API | Foundation for everything | GPL | Very active, 1.0 beta line, docs at docs.smods.dev | **Use as the only hard dependency** |
| **Lovely** | Runtime injector + patch format | Load mechanism; escape hatch for patches | MIT-family | Active | **Required transitively; avoid writing our own patches if possible** |
| **Balatro-DeckCreator** (adambennett) | Create/save/share custom decks; Starting Items tab adds Jokers/consumables/vouchers incl. editions & modded content | ~70% of Run Builder feature list | GPL | Stale-ish; community reports GUI crashes on current SMODS; contains Balamod-era dual-loader code | **Don't fork, don't depend. Reuse concepts + selectively lift GPL snippets (start-run injection, save-file format ideas)** |
| **ZokersModMenu** (1Zoker) | In-run cheat menu: starting Jokers with editions, custom decks, give items, money, slots, ante scaling, console commands | Starting-Joker + edition selection | **No license found** | Active-ish 2025 | **Avoid code reuse entirely (unlicensed). Reuse ideas only (e.g., edition button UX, modded-Joker prefix handling)** |
| **Galdur** (Eremel) | Overhauls run-setup menu (deck grid, stake page); public API for other mods to add setup pages | The exact UI slot our Builder belongs in | Check repo (GitHub) | Maintained; being folded into SMODS as "Run Select Pages" | **Reuse the pattern: our Builder = a page in run setup. Optional soft-compat: register a Galdur page if Galdur present** |
| **Cryptid** (SpectralPack) | 210 Jokers; **Exotic rarity above Legendary** (never in shop, summoned via Gateway spectral); Epic rarity in shop | Proof + reference implementation for Impossible rarity & absurd-but-coherent Joker design | GPL | Very active, large team | **Reuse the rarity pattern and balance philosophy; read its SMODS.Rarity usage as reference** |
| **DebugPlus / built-in Debug Menu** | Spawn any card/Joker, edition tools, hotkeys | Dev tooling only | OSS | Active | **Use during development for fast testing; not a dependency** |
| **Joker Studio–type "make a Joker" tools** | GUI joker creation | None for V1 (our Jokers are hand-coded) | varies | fragmented | **Avoid** |
| **awesome-balatro** (jie65535) | Curated mod/tool index | Discovery | — | Updated 2026 | **Bookmark for the repo docs** |

**Should the Run Builder be based on an existing mod? No.** DeckCreator is the only real candidate and it fails on maintenance status, SMODS-1.0 alignment, and UI quality (grid-of-everything admin feel, exactly what the brief forbids). The build cost of our narrower, Joker-first Builder on current SMODS APIs is *lower* than the cost of modernizing DeckCreator.

---

## 4. Build vs fork vs reuse matrix

| Capability | Build | Fork | Reuse | Decision |
|---|---|---|---|---|
| Mod scaffold, loading, config | — | — | SMODS provides | SMODS |
| Run-setup entry point ("Build Lab" tab) | ✅ small | — | Pattern from Galdur / vanilla `G.UIDEF.run_setup_option` | Build (thin) |
| Joker picker with real cards + tooltips | ✅ | DeckCreator has one (broken, ugly) | Pattern from vanilla Collection screen | Build, copying vanilla's own UI pattern |
| Edition assignment | trivial | — | `SMODS.add_card{edition=...}` | SMODS |
| Run injection (deck/stake/money/hands/jokers) | ✅ small | — | Vanilla Challenge system + DeckCreator's GPL injection code as reference | Build on Challenge pattern |
| Preset save/load/share | ✅ small | — | SMODS config + DeckCreator's txt-merge idea | Build |
| Custom rarity | — | — | `SMODS.Rarity`; Cryptid as reference | SMODS |
| 5 Impossible Jokers | ✅ (the fun part) | — | SMODS.Joker; Cryptid for "absurd but coherent" calibration | Build |
| Modded-Joker support | free | — | `G.P_CENTER_POOLS` includes them | Free via SMODS |

---

## 5. Product architecture

Two loosely-coupled modules in one mod, so each survives without the other:

1. **`buildlab/` — the Run Builder.** UI + config model + run injection. Zero knowledge of our custom Jokers; it just lists whatever is in the Joker pool (so it automatically lists Impossible Jokers, Cryptid Jokers, anything).
2. **`impossible/` — the content pack.** `SMODS.Rarity` + five `SMODS.Joker` definitions + atlas + localization. Works standalone: with the Builder disabled in config, the Jokers are still obtainable via a config toggle ("allow Impossible in shop at tiny weight") or a future spawner mechanic.

Data flow:

```
Build Lab UI  →  RunConfig table  →  serializer (presets.lua ↔ JSON on disk)
                      │
                      ▼
        start_run adapter (challenge-shaped ruleset + post-start SMODS.add_card
        for per-slot editions/stickers)  →  normal Balatro run
```

Design rules:
- **No base-game file edits ever.** Everything through SMODS objects and function hooks (wrap-and-call-original on e.g. `G.FUNCS.start_run`). Lovely `.toml` patches only as a last resort, and each one documented in `docs/patches.md` with the vanilla snippet it targets (so updates are diffable).
- **Native UI only.** Every screen is a `UIBox` built from vanilla helpers; every Joker shown is a real `Card` in a `CardArea` (real art, real tooltips, real hover wobble, real sounds).
- **Config is data, not code.** A preset is a plain table `{ name, deck, stake, jokers = { {key, edition, stickers}, ... }, params = {...}, seed }` — trivially serializable, shareable, and validatable (unknown keys from uninstalled mods degrade gracefully to a warning slot, never a crash).

---

## 6. V1 feature scope

**MUST HAVE (V1)**
- "Build Lab" button on the run-setup screen (and main menu shortcut)
- Deck selector (all loaded decks incl. modded — iterate `G.P_CENTER_POOLS.Back`)
- Stake selector (all loaded stakes)
- 5 Joker slots; tap a slot → picker
- Picker: paged grid of real Joker cards, text search box, rarity filter; hover = native tooltip
- Edition assign per slot: Base / Foil / Holographic / Polychrome / Negative
- Starting money, hands, discards, hand size, Joker slots, consumable slots (simple number cyclers — the challenge system already supports all of these)
- Optional seed field
- Start Run → real run, saveable/resumable like any run
- Presets: save (named), load, delete; persisted across restarts
- Impossible rarity + all 5 Impossible Jokers, fully playable, Blueprint/Brainstorm-safe
- Ships with 2 built-in presets: **Facepocalypse** and **Baron Machine**

**SHOULD HAVE (V1.x)**
- Eternal / Perishable / Rental stickers per slot (SMODS.Sticker API; small)
- Duplicate preset; preset export/import as compact string (base64 of JSON) for sharing
- Starting vouchers + starting consumables
- Galdur soft-integration (register as a Galdur page when Galdur is loaded)
- Config toggle: "Impossible Jokers can appear in shop" (weight ~0.1%)

**LATER**
- A diegetic acquisition path for Impossible Jokers in normal runs (a Soul-like spectral, à la Cryptid's Gateway)
- Custom deck composition editing (this is DeckCreator's whole domain — stay out of it)
- Share codes with checksums; preset browser
- Challenge-mode export (turn a preset into a real SMODS.Challenge)
- Animated shader badge for Impossible edition-style glow

---

## 7. Custom Run Builder UX (native-feeling)

Flow (mirrors vanilla conventions, controller-friendly):

1. **Entry:** In the New Run window, alongside deck/stake, a third tab: **BUILD LAB** (same tab style as "New Run / Continue / Challenges"). Also `Main Menu → PLAY → Build Lab`.
2. **Main panel** (one screen, no scrolling):
   - Top: deck + stake cyclers, drawn exactly like vanilla run setup (deck card preview on the left, stake chips column).
   - Middle: a `CardArea` with 5 face-up slots. Empty slot = face-down card back with a "+" tag. Filled slot shows the real Joker card with its edition shader applied live; hovering shows the real tooltip. Below each card: a small edition cycle chip (Base→Foil→Holo→Poly→Negative) using vanilla badge colours.
   - Bottom row: money / hands / discards / hand size cyclers (collapsed behind an "Advanced" toggle so the default screen stays clean), seed input, **PRESETS** button, big orange **START RUN** button (vanilla `G.C.ORANGE`, vanilla button sound).
3. **Joker picker** (modal, styled like the Collection): search box top-left (vanilla text input), rarity filter tabs (Common/Uncommon/Rare/Legendary/Impossible/Modded), paged grid of real cards, click = select + `play_sound('card1')`. Impossible cards get their own badge colour so the rarity reads instantly.
4. **Presets** (modal): vanilla list rows — name, deck icon, 5 mini Joker sprites, Load / Overwrite / Delete. "Save current as…" opens vanilla text input. Presets referencing missing modded Jokers load with that slot empty + a subtle warning tooltip ("requires mod: Cryptid").
5. **Feel:** every interaction uses existing sounds (`button`, `cardSlide1`, `tarot1` on Start), vanilla easing/juice (`card:juice_up()` when a Joker is placed), vanilla fonts/colours from `G.C`. Nothing custom-drawn.

---

## 8. The Impossible rarity

**Recommended name: IMPOSSIBLE.** Keep it. Balatro's vocabulary is stage magic and card sharps, not high fantasy — Common/Uncommon/Rare/Legendary are deliberately plain. "The impossible card trick" is genuine magician vocabulary, it sits naturally after "Legendary", and it doubles as a promise ("this shouldn't be allowed"). Runner-up: **Marked** (card-cheat slang — great flavour, but reads like a mechanic, not a tier). Reject Mythic/Transcendent/Unbound (generic gacha-speak), Forbidden/Paradox (edgy-fantasy).

Registration sketch (verify exact fields against docs.smods.dev/Game Objects/SMODS.Rarity before coding):

```lua
SMODS.Rarity{
    key = 'impossible',
    loc_txt = { name = 'Impossible' },
    badge_colour = HEX('AA0F3C'),      -- deep card-suit crimson w/ subtle pulse via gradient later
    default_weight = 0,                -- never rolls naturally in V1
    pools = { Joker = true },
}
```

Rules of the tier (mirrors Cryptid's proven Exotic pattern):
- Weight 0: never appears in shops/packs/The Soul in V1 (config toggle can set a tiny weight later).
- Obtainable only via the Build Lab in V1.
- All five are `unlocked = true`, `discovered` on first sight, `perishable_compat = false` where the design breaks, `eternal_compat = true` unless noted.
- Cost band: $50 (so selling one ≈ a Legendary's worth; matters if "allow in shop" is toggled).
- Exactly five at launch; the family covers five broken-build archetypes: **destruction-scaling XMult, Negative-Joker engine, retriggers, copy/positioning, deck transformation.**

---

## 9. The five Impossible Jokers

> Numbers below are tuned to be absurd-but-coherent for a sandbox tier. Every card must set `blueprint_compat` and `eternal_compat` explicitly and be tested with Blueprint, Brainstorm, and Showman.

### 9.1 The Fun Hoe *(required name — court-intrigue chaos)*
- **Flavor concept:** The royal court's most beloved menace: a grinning jester who "tends the royal garden" with an enormous farming hoe, cheerfully harvesting courtiers. Medieval intrigue as agriculture. No GoT anything — original character, original iconography.
- **Rules text:** *"Scored face cards are harvested after scoring. This Joker gains **X0.5 Mult** for each harvested card. (The court grows back: harvested cards return if this Joker is sold.)"*
- **Trigger timing:** `context.destroying_card` marking + post-scoring destruction (same phase as Glass breaking); XMult applies in `joker_main`.
- **Base values:** X1 Mult base; +X0.5 per harvest, permanent for the run. Sell value $50→$25.
- **Scaling:** unbounded, gated by your supply of face cards — a real strategic resource.
- **Blueprint/Brainstorm:** compatible — copies deliver the *current* XMult only, never the harvesting (destruction must not double-fire; guard with `card ~= self.card` checks). `blueprint_compat = true`.
- **Eternal:** compatible. **Perishable:** incompatible (losing accumulated XMult mid-run feels awful) — `perishable_compat = false`.
- **Natural appearance:** no (weight 0). **Soul:** not generated by The Soul in V1.
- **Key interactions:** *Pareidolia* = every scored card is a face → entire hands harvested → monstrous scaling while your deck evaporates (the Facepocalypse preset becomes a self-destruct engine — intended!). *Sock and Buskin* retriggers fire **before** harvest. *Glass/steel* face cards work (harvest supersedes glass-break; count once). *DNA/The Forger* replenish the garden. *Hanging Chad* retriggers the first scored card even if it's about to be harvested.
- **Edge cases:** deck can empty → the game already handles low-deck states, but test hands with fewer cards than hand size; Stone face cards (impossible — Stone has no rank, cannot be a face) — skip; debuffed face cards score nothing and are **not** harvested.
- **Balance/fun:** classic engine-with-a-fuse. Every play is a bargain: power now, deck later. The best "one more run" card in the set.
- **Rarity/cost/weight/unlock:** Impossible / $50 / 0 / none.

### 9.2 Bambino *(required name — tiny boss, Negative engine)*
- **Flavor concept:** A baby-faced casino emperor in a three-sizes-too-big pinstripe suit, cigar-shaped lollipop, pinky ring. Everyone works for Bambino.
- **Rules text:** *"At end of round, the Joker to the right of Bambino **joins the family** (becomes Negative). **X1 Mult** plus **X0.5 Mult** for each Negative Joker."*
- **Trigger timing:** conversion in `context.end_of_round` (main, non-blind-specific); XMult in `joker_main`.
- **Base values:** X1 + 0.5·(negative joker count). One conversion per round — a hard, elegant rate limit.
- **Scaling:** linear with Negatives; explodes with *Invisible Joker* (duplicating Negatives), *Perkeo*-adjacent economy builds, and the Build Lab itself (start with 4 Negatives → X3 out of the gate).
- **Blueprint/Brainstorm:** copies the XMult only; the conversion is Bambino's alone (`blueprint_compat = true`, conversion guarded to the real card). Brainstorm-as-leftmost copying Bambino gives XMult — fine.
- **Eternal:** compatible. Conversion respects Eternal/already-Negative (skips them; picks nothing else — the seat at Bambino's right hand matters).
- **Natural appearance / Soul:** no / no.
- **Key interactions:** *Showman* + shop = stack duplicate Jokers, feed them to Bambino. Making *Blueprint* Negative then repositioning = free copy engine. Converting *Invisible Joker* keeps its timer. Positioning mini-game: who sits at the boss's right hand this round?
- **Edge cases:** Bambino rightmost = no conversion (he sulks; show a small `juice_up`); converting a Joker that's already Negative = skip, no reroll; cap total Jokers at slot limit — Negative slots are the whole point.
- **Balance/fun:** turns Joker *positioning* and shop scavenging into the build. The set's economy/army archetype.
- **Rarity/cost/weight/unlock:** Impossible / $50 / 0 / none. `perishable_compat = false`.

### 9.3 Jazzy Clown *(required name — the dog, retrigger engine)*
- **Flavor concept:** Not a dog in a clown suit — a **circus poster of a legendary performing dog**: ruff collar, tiny cone hat, mid-leap through a paper hoop shaped like a card. Iconic, abstract, poster-style.
- **Rules text:** *"**Fetch:** retrigger the leftmost scored card 3 times. Every 3rd hand played, Jazzy learns a new trick: **+1 retrigger**. **1 in 4 chance** each hand for **Zoomies**: retrigger *all* scored cards once."*
- **Trigger timing:** `context.repetition` for both Fetch (leftmost card) and Zoomies (all scored); trick-learning counter increments in `context.after` per hand played.
- **Base values:** 3 retriggers, +1 per 3 hands (permanent, uncapped); Zoomies 1-in-4 (respects `SMODS.pseudorandom_probability`, so *Oops! All 6s* doubles it → guaranteed at 2 stacks).
- **Blueprint/Brainstorm:** retriggers copy cleanly (`blueprint_compat = true`) — copied Jazzy re-fetches; trick-learning counter only advances on the real card.
- **Eternal:** compatible; the ideal Eternal (you never want to sell the dog).
- **Natural appearance / Soul:** no / no.
- **Key interactions:** *Photograph* + a face card leftmost = X2 stacked per fetch. *Hanging Chad* stacks additively on the same leftmost card. *Red Seals/steel/gold/glass/Bloodstone/Lucky* all multiply with retriggers — this is the set's probability-and-retrigger playground. *Baron/Mime* are held-in-hand (unaffected — intentional separation from the Baron Machine preset).
- **Edge cases:** leftmost scored card destroyed mid-scoring (Glass, Fun Hoe) — retriggers already queued must resolve (test!); Zoomies + Fetch on the same card must not infinite-loop (retriggers never trigger repetition contexts again — vanilla rule, verify).
- **Balance/fun:** grows every three hands like a training montage; Zoomies makes every play a slot machine. Charm carries it.
- **Rarity/cost/weight/unlock:** Impossible / $50 / 0 / none. `perishable_compat = false`.

### 9.4 The Understudy *(invented — copy/positioning)*
- **Flavor concept:** A gaunt stagehand in the wings, half in shadow, clutching a script, mouthing every line. One spotlight away from stardom.
- **Rules text:** *"Copies the abilities of the Jokers **directly left and right** of this card."*
- **Trigger timing:** every context, delegated (same machinery as Blueprint but bidirectional; implement via `SMODS.blueprint_effect`-style delegation per current SMODS calc docs).
- **Base values:** none — pure mirror.
- **Scaling:** whatever its neighbours scale.
- **Blueprint/Brainstorm:** the chaos centrepiece. Blueprint→Understudy→X chains resolve like vanilla copy chains; self-reference and cycles must resolve to nothing (vanilla already guards Blueprint↔Blueprint — reuse that exact guard). `blueprint_compat = true` (it can be copied, yielding its current targets).
- **Eternal:** compatible.
- **Natural appearance / Soul:** no / no.
- **Key interactions:** flanked by two Blueprints pointed elsewhere = 3 extra copies of things; next to Baron + Mime = the Baron Machine preset's fifth slot; next to Jazzy = double Fetch.
- **Edge cases:** edge positions copy only one neighbour; copying non-copyable Jokers (blueprint_compat=false) yields nothing, same as Blueprint; Understudy next to Understudy = both mirror outward only (cycle guard).
- **Balance/fun:** pure positioning puzzle; the card that makes players screenshot their Joker row.
- **Rarity/cost/weight/unlock:** Impossible / $50 / 0 / none. `perishable_compat = true` (it holds no state).

### 9.5 The Forger *(invented — deck transformation)*
- **Flavor concept:** A back-room printer surrounded by drying sheets of "money", ink-stained fingers, a loupe in one eye. Every card that crosses the table leaves… improved.
- **Rules text:** *"When a hand is played, each scored card with no enhancement gains a **random enhancement**, and one random scored card gains a **Red Seal**."*
- **Trigger timing:** `context.after` (post-scoring, pre-discard), with vanilla enhancement-apply juice/sound per card.
- **Base values:** enhancement pool = vanilla 8 (Bonus/Mult/Wild/Glass/Steel/Stone/Gold/Lucky), uniform; exactly one Red Seal per hand.
- **Scaling:** your *deck* scales, not the Joker — after ~15 hands the whole deck is enhanced and stamped.
- **Blueprint/Brainstorm:** **not copyable** (`blueprint_compat = false`) — double-stamping per hand snowballs the deck too fast and doubles RNG events; also mirrors vanilla precedent that deck-mutators (e.g. DNA) are copyable but per-card mass mutation is not. This is the set's deliberate non-Blueprint card.
- **Eternal:** compatible.
- **Natural appearance / Soul:** no / no.
- **Key interactions:** Steel + Red Seal feeds *Baron/Mime*; Glass feeds *The Fun Hoe*; Lucky feeds *Oops! All 6s/Bloodstone*-style probability builds; *Midas Mask* (forces Gold on faces) competes for the same cards — Forger skips already-enhanced, so Midas wins on faces (coherent). Red Seals + Jazzy = retrigger salad.
- **Edge cases:** Stone result on a scoring card is legal (it scored this time as its old self; becomes Stone after); Wild results can enable flush decks accidentally — accepted chaos; save/reload mid-round must not re-stamp (stamp only in `after`).
- **Balance/fun:** every run becomes a unique artifact deck; the transformation archetype without touching consumables.
- **Rarity/cost/weight/unlock:** Impossible / $50 / 0 / none. `perishable_compat = true`.

**Set coherence check:** Fun Hoe (XMult via destruction) ↔ Forger (creates Glass to destroy) ↔ Jazzy (retriggers what Forger stamps) ↔ Understudy (mirrors any of them) ↔ Bambino (makes room for all of them). Five archetypes, heavy cross-synergy, no two cards competing for the same job.

---

## 10. Art-direction briefs (for later image-gen prompts)

**Global style guide (prepend to every prompt):** hand-drawn pixel-adjacent playing-card art in the spirit of Balatro's Joker cards but wholly original; flat limited palette (5–7 colours per card); thick dark outlines; slightly crude, folk-art/carnival-poster energy; strong single-subject silhouette readable at 71×95 px; plain dark card-face background with subtle vignette; **no** gloss, **no** photorealism, **no** painterly AAA fantasy, **no** text on the card, **no** existing Balatro character likenesses.

1. **The Fun Hoe:** manic jester in a two-tone cap-and-bells (crimson + moss green), hoisting an oversized rustic garden hoe over one shoulder like a royal banner; a single tiny crown skewered on the hoe's blade; wide crescent grin; body tilted in a mid-caper lunge. Silhouette anchor: the diagonal hoe.
2. **Bambino:** round baby-faced boss, 2-heads-tall proportions, swallowed by a pinstripe suit; oversized fedora tipping over one eye; lollipop held like a cigar; pinky ring glinting as a single white pixel star; smug half-lidded eye. Palette: charcoal suit, cream face, gold accents. Silhouette anchor: hat-dome over tiny body.
3. **Jazzy Clown:** vintage circus-poster dog mid-leap through a torn paper hoop; ruff collar and mini cone hat; ears flying; motion trail as three echo outlines behind (foreshadows retriggers). Palette: cream dog, red-and-gold hoop, deep blue background. Silhouette anchor: horizontal leaping arc.
4. **The Understudy:** gaunt figure half-consumed by stage-curtain shadow, one hand clutching a rolled script, eyes reflecting an off-frame spotlight; the lit half rendered in warm gold, the shadowed half in near-black violet — a card split vertically light/dark. Silhouette anchor: the hard light/dark seam.
5. **The Forger:** hunched printer at a tiny press, loupe screwed into one eye (drawn as a monocle-circle), sheets of freshly "printed" playing cards hanging on a line above like laundry; ink-black fingertips. Palette: sepia + ink black + one counterfeit-green accent. Silhouette anchor: the hanging card-laundry line.
---

## 11. Technical architecture — the 20 questions answered

1. **Recommended stack:** Lovely injector + Steamodded 1.0 beta line. Nothing else as a hard dependency.
2. **Lovely's role:** runtime injector; loads Lua into the game at startup and offers a declarative patch format. We inherit it via SMODS and ideally never write our own patches.
3. **SMODS's role:** mod loading, all content APIs (Joker/Rarity/Atlas/Sticker/Challenge), calc event system, localization, config persistence, utility spawn functions.
4. **Where files live:** `%AppData%/Balatro/Mods/BuildLab/` (Windows) — one folder, self-contained, with a SMODS metadata JSON. Git repo = that folder.
5. **No permanent base-game edits:** correct, guaranteed by the stack. Lovely patches memory only.
6. **Run-start hook:** translate the Build Lab config into a challenge-shaped ruleset passed to the vanilla run-start path (`G.FUNCS.start_run` with a `challenge` table / `SMODS.Challenge` machinery), then a post-start step for anything the ruleset can't express. The challenge system natively handles starting money/hands/discards/hand size/jokers — reuse it rather than re-implementing.
7. **Spawning Jokers with editions:** `SMODS.add_card{ set='Joker', key=..., edition='e_negative', area=G.jokers }` per slot. Stickers (Eternal etc.) set on the returned card (`card:set_eternal(true)` / SMODS sticker API — verify exact call in docs).
8. **Custom rarity:** `SMODS.Rarity` with weight 0 (§8).
9. **Custom Jokers:** `SMODS.Joker` with Better-Calc `calculate` contexts (§9).
10. **Presets:** small Lua table ↔ JSON in the mod folder via LÖVE filesystem (SMODS config for settings; separate `presets.json` for user data, DeckCreator-style so users can share the file).
11. **Searchable Joker list:** iterate `G.P_CENTER_POOLS['Joker']`; filter on localized name via `localize{...}`/center `name`; render as real Cards in a paged CardArea (vanilla Collection pattern).
12. **Modded-Joker support:** free — pools include all loaded mods. Store `key` (which is prefix-namespaced by SMODS); on preset load, `if not G.P_CENTERS[key] then mark slot missing`.
13. **Reusing native cards/tooltips in the picker:** yes — instantiate real `Card` objects; hover tooltips, edition shaders, and rarity badges come along automatically.
14. **Maintaining visual style:** build all UI as `UIBox` trees with vanilla helpers (`create_option_cycle`, `UIBox_button`, text inputs), vanilla `G.C` colours, vanilla sounds. Never draw custom chrome.
15. **Existing UI components to reuse:** vanilla `functions/UI_definitions.lua` (run setup, collection pages, option cycles), SMODS "UI Structure" guide, Galdur's page-registration pattern.
16. **SMODS UI limitations:** no reactive framework — UIBoxes are rebuilt, not diffed; text input is basic; long lists need manual paging; controller focus must be declared per node. Design around paging + modals (as vanilla does).
17. **Lovely patches needed?** Likely zero for V1. Possible exception: if the run-setup tab row proves hostile to injection via function wrapping, one small, documented `lovely.toml` pattern-patch on the run-setup UI definition.
18. **Avoid Lovely patching entirely?** Plausible and the goal; keep the escape hatch documented.
19. **Defer from V1:** custom deck composition, share codes, in-run acquisition of Impossible Jokers, animated custom shaders, voucher/consumable pickers (SHOULD tier), any base-game screens beyond the one tab.
20. **Update resilience:** (a) depend on documented SMODS APIs, never on line-number patches; (b) all vanilla-function hooks in one file (`src/hooks.lua`) wrap-and-call-original; (c) pin minimum SMODS version in metadata; (d) smoke-test checklist (§14) after every Balatro/SMODS update; (e) content pack isolated from UI so a UI break never bricks the Jokers.

---

## 12. Repository structure

```
BuildLab/
├── buildlab.json            # SMODS metadata: id, prefix "bl", deps (Steamodded >= 1.0.0-beta), version
├── main.lua                 # entry: requires modules in order, nothing else
├── lovely/                  # (empty in V1; documented escape hatch)
├── src/
│   ├── hooks.lua            # ALL vanilla function wraps live here, each with a comment block
│   ├── run_config.lua       # RunConfig model + validation + defaults
│   ├── run_injector.lua     # config -> challenge ruleset + post-start add_card
│   ├── presets.lua          # save/load/JSON, missing-mod degradation
│   └── ui/
│       ├── buildlab_tab.lua # run-setup tab registration
│       ├── main_panel.lua   # deck/stake/slots/params screen
│       ├── joker_picker.lua # searchable paged picker
│       └── presets_modal.lua
├── impossible/
│   ├── rarity.lua           # SMODS.Rarity
│   └── jokers/              # one file per joker: fun_hoe.lua, bambino.lua, jazzy_clown.lua,
│                            #   understudy.lua, forger.lua
├── assets/
│   ├── 1x/  └── 2x/         # atlases: Jokers_bl.png (5 cards, 71x95 grid @1x)
├── localization/
│   └── en-us.lua
├── docs/
│   ├── architecture.md      # this plan, condensed + kept current
│   ├── conventions.md       # naming, prefixing, calc-context cheatsheet
│   ├── smods-notes.md       # verified API signatures w/ links + date checked
│   ├── patches.md           # any lovely patch + the vanilla code it targets
│   └── test-checklist.md
├── CLAUDE.md                # agent operating manual (see §15; symlink/duplicate as AGENTS.md)
└── README.md                # player-facing install (drop folder in Mods/)
```

---

## 13. Milestone implementation plan (agent-sized steps)

**M0 — Environment.** Install Lovely + SMODS; extract Balatro source to `../balatro-src/` (gitignored) for reference; confirm vanilla runs modded; add DebugPlus for dev. *DoD:* SMODS mod list opens; `docs/smods-notes.md` created with doc links.
**M1 — Mod boots.** Metadata JSON + main.lua + a log line. *Files:* buildlab.json, main.lua. *Risk:* metadata format drift — copy from a current SMODS example mod. *DoD:* BuildLab listed in Mods menu, no crash, log visible in Lovely console.
**M2 — Impossible rarity + 1 placeholder Joker.** Rarity registers; one Joker (Understudy stub with X2 Mult placeholder) spawnable via debug menu, badge shows "Impossible". *DoD:* joker in collection, tooltip renders, badge coloured. (Content before UI: it de-risks the atlas/localization pipeline early.)
**M3 — Run injection, no UI.** Hardcoded config table → start run with Red deck, White stake, 2 known Jokers with editions, $20. Entry via a temporary keybind (SMODS.Keybind). *Files:* run_config, run_injector, hooks. *Risks:* edition keys (`e_foil` etc.), challenge-table shape — read vanilla challenge definitions first. *DoD:* run starts with exact expected state; save/continue works; vanilla New Run unaffected.
**M4 — Build Lab tab + main panel.** Real screen: deck/stake cyclers + Start button wired to M3. *DoD:* full flow mouse + controller.
**M5 — Joker picker.** Paged grid of real cards from pools, search, rarity filter; fills slots. *Risk:* CardArea lifecycle in menus (leaks/ghost cards) — mirror the Collection screen's create/teardown. *DoD:* pick 5, hover tooltips correct, includes modded Jokers when another mod is installed.
**M6 — Edition selector + advanced params.** Edition cycle chip under each slot with live shader preview; money/hands/discards/hand-size cyclers; seed input. *DoD:* Facepocalypse manually buildable and startable.
**M7 — Presets.** Save/load/delete/named; JSON on disk; graceful missing-mod slots; ship Facepocalypse + Baron Machine built-ins. *DoD:* survives game restart; corrupt file → safe reset with warning, not crash.
**M8 — The five Impossible Jokers, for real.** One per commit, each with its `calculate` logic + localization + atlas slot + interaction tests (Blueprint, Brainstorm, Showman, retriggers). *DoD:* full test-checklist pass per joker.
**M9 — Polish + hardening.** Sounds, juice, controller focus order, config toggles (disable Builder / allow-in-shop weight), README, version 1.0.0. *DoD:* full §14 checklist green on clean install.

Each milestone = one PR-sized unit; each ends with a manual in-game verification before the next begins.

---

## 14. Testing strategy

No headless test rig exists for Balatro; testing is empirical + fast-reload (`Alt+F5` restarts the game with mods). Maintain `docs/test-checklist.md`:

**Boot:** clean install boots vanilla; +Lovely boots; +SMODS boots; +BuildLab boots; BuildLab disabled via SMODS toggle → vanilla behaviour byte-identical.
**Builder:** every deck incl. modded; every stake; empty slots (0–5 Jokers); duplicate Joker in 2+ slots; same Joker ×5; each edition per slot; 5×Negative (slot math!); seed respected (two runs, same seed, same shop); advanced params each min/mid/max.
**Injection:** started run is saveable/continuable; Joker order preserved; Negative Jokers don't consume slots; stickers correct (V1.x).
**Impossible Jokers:** each alone; each + Blueprint; each + Brainstorm; each + Showman duplicates; Fun Hoe + Pareidolia (deck-drain over 10 hands, no crash on tiny deck); Bambino rightmost / all-Negative row / converting Eternal-adjacent; Jazzy leftmost-card-destroyed mid-score, Zoomies + Oops! All 6s; Understudy at row edges, Understudy×2 adjacent, Understudy next to Blueprint chain; Forger + Midas Mask, Forger save/reload mid-round (no double stamp).
**Presets:** save/load/delete; restart persistence; preset referencing uninstalled modded Joker → warning slot, run still startable; hand-corrupted JSON → reset with message.
**Compat matrix:** BuildLab + Cryptid, + Galdur, + Talisman, + a deck-adding mod — picker lists their content, runs start, no calc crashes.
**Regression cadence:** rerun Boot + one full Builder flow + one Joker-interaction spot check after every SMODS/Balatro update.

---

## 15. Vibe-coding workflow (Claude Code / Codex)

**Repo docs the agent must have:**
- `CLAUDE.md` (and `AGENTS.md` mirror): operating manual — "read before writing" rules below, build/run instructions, where logs are, how to hot-restart (`Alt+F5`), commit conventions.
- `docs/smods-notes.md`: **the anti-hallucination ledger.** Every SMODS/vanilla API we use gets an entry: exact signature, source link (docs.smods.dev page or file+line in SMODS/vanilla source), date verified. Agents may only call APIs that have a ledger entry or add one by citing source.
- `docs/architecture.md`, `docs/conventions.md`, `docs/test-checklist.md`, `docs/patches.md` as above.

**Hard rules for the agent (put verbatim in CLAUDE.md):**
1. Never invent an API. Before calling anything on `SMODS.*`, `G.*`, or `Card`, find it in: (a) docs.smods.dev, (b) SMODS source in `../smods/`, (c) extracted vanilla source in `../balatro-src/`, or (d) a GPL mod in `../reference-mods/` (DeckCreator, Cryptid, Galdur checked out read-only). Record it in `smods-notes.md`.
2. Copy patterns from GPL references freely with a comment crediting file+project; never from ZokersModMenu (no license).
3. Smallest possible change → run the game → verify with the checklist item → commit. One feature per commit, message format `M5: joker picker paging`.
4. When the game crashes, read the Lovely log/crash dump first; do not guess-fix.
5. UI work: find the closest vanilla screen, read its UIDEF function, imitate its node structure.
6. If Balatro/SMODS updates break the mod: `git log docs/smods-notes.md` to see which APIs we depend on, re-verify each against the new source, fix `hooks.lua` first (it's the only file allowed to touch vanilla functions).

**Human loop:** the agent cannot see the game. You are the eyes: run, screenshot, paste crash logs. Keep sessions scoped to one milestone.

---

## 16. Risks & mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| SMODS 1.0 API churn (beta) | Medium | Ledger of verified APIs; pin min version; hooks isolated |
| SMODS ships built-in "Run Select Pages" that collides with our tab | Medium | Our tab registration lives in one file; adapt to become a page in their system (it's Galdur-derived, our design already matches) |
| Menu CardArea leaks/ghost sprites | Medium | Mirror Collection screen lifecycle exactly; test open/close ×20 |
| Copy-chain bugs (Understudy) | Medium | Reuse vanilla Blueprint guard verbatim; dedicated test matrix |
| Balatro content update changes challenge table shape | Low | Injection goes through one adapter file |
| Preset files from other users are malicious/corrupt | Low | JSON only, schema-validate, never `load()` preset data |
| Scope creep into DeckCreator territory | High (self-inflicted) | LATER list is a fence: no deck-composition editing in V1 |

---

## 17. Recommended first implementation task

**M1+M2 in one session:** boot a metadata-valid SMODS mod that registers the Impossible rarity and one placeholder Impossible Joker with temporary art, visible in the collection with a coloured badge and working tooltip, spawnable via the debug menu.

It's small, it exercises the entire toolchain (metadata → load order → atlas → localization → SMODS objects → in-game verification), it produces a screenshot-able win in under an hour, and it seeds `docs/smods-notes.md` with the first verified APIs — establishing the empirical workflow everything else depends on.
