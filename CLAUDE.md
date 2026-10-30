# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## State of the repo

**Nursing Home Cat of SPLORR!!** (working title): a therapy cat makes afternoon rounds at a care home and cannot visit everyone. Chosen by the user October 30, 2026 from `docs/IDEAS.md`; the design and the user's decisions are in `docs/DESIGN.md`. The scaffold runs (title, movable cat, residents, energy, ledger); the real rules are still to do.

## Commands

```bash
tools/test.sh          # regenerates font_data.odin and tile_data.odin, runs native tests, type-checks both packages for js_wasm32
tools/build.sh         # build/web (add --size for the shipping build)
python3 -m http.server -d build/web 8000   # the wasm must be served over http, not file://
odin test odin/game -collection:nhc=odin -define:ODIN_TEST_THREADS=1 -define:ODIN_TEST_NAMES=game.<test_name>   # one test
```

## Architecture

- `odin/game` is a pure package (no platform calls): `Game` state, `game_init`, `game_command(cmd, down)`, `game_frame(dt)`. It draws into a 320 by 180 hue-index `Canvas` and converts to RGBA in `Game.pixels`. Because it is pure, native tests drive it directly; `game_test.odin` is `#+build !js` so the wasm type-check skips it. `Game` is about 280 KB: heap-allocate it in tests, never on the stack.
- `odin/platform/web` is `step` plus `platform_*` exports; `web/index.html` blits the RGBA frame, maps keys and an on-screen pad. Imported as the collection `nhc` (`-collection:nhc=odin`). The `odin.js` runtime is copied from the Odin install at build time.
- `odin/game/tile_data.odin` is **generated** by `tools/gen_tiles.py`, which cuts the listed (col, row) tiles out of the Urizen 1-bit sheet in `assets/tiles/` (CC0, credit vurmux). Tiles are one-colour masks; the game picks the hue. To use another tile, add it to `TILES` in the script. Find tile coordinates with the bok's `Tech/Urizen tile catalogue.md` and `Tech/urizen-crop.py`.
- `odin/game/font_data.odin` is **generated** by `tools/gen_font.py` from `assets/fonts/dbyte_1x.png` (DINOBYTE, CC BY 4.0, needs credit). Do not edit it by hand.
- Sound: the game raises `Sfx` values into `Game.sfx`; the page polls `platform_sfx_*` each frame and plays `sfx/<name>.wav`. The `SOUND_FILES` list in `web/index.html` must match the `Sfx` enum order. Sounds live as PLAY text in `assets/anvil/world.json` (Anvil world) and are exported to `assets/sfx/` with `sound_export`.
- Saves: `odin/game/save.odin` (one line of text under `nhc:run`, validated field by field in `parse_save`); the platform passes `Storage{get, set}` to `game_init` and either proc may be nil. If you add state to `Game` that must survive a visit, extend `SaveData`, bump `SAVE_TAG`, and extend the damaged-save test.
- Same shape as T!ts UUp!! (`/home/yermom/git/tits-up`); copy from it when adding saves (localStorage via the platform shim) or sound.

## Governance and tooling (outside this repo)

- **The bok** (`/home/yermom/git/bok-of-splorr`, an Obsidian vault in `splorr/`) is the rulebook. Read `splorr/Home.md`, section "Standing rules for sessions working in this vault", before doing anything non-trivial; also `Concepts/Metaphor design.md`, `Tech/Odin wasm recipe.md`, `Tech/Release standard.md`, `Tech/GitHub Pages.md` and `Gotchas.md`. When this game is real, add `Games/<name>.md` (full frontmatter, `repo:` pointing here, `pages:` field) to the bok and link it from `Home.md`.
- **Coxswain** (MCP server `coxswain`) tracks tasks. Project name: `cat-titties-farts`. **This session's agent name is `ctf`**; every Coxswain call that changes a task needs `agent` (and `task_note` takes its text in `text`). Register with `agent_register {agent: "ctf"}` once per session.
- **The Anvil** (MCP server `anvil-prod`) makes sprites, tiles, maps, palettes and sounds. `world_export` writes the world JSON and `sound_export` a WAV; a small stdlib-only script packs sprites into an atlas at build time. Check PLAY text with `sound_check` before rendering (`T120 O2 L4 CD-C` is about 1.5 s).

## Rules from the bok that bite here

- Target is **Odin compiled to `js_wasm32`** (HTML5 canvas via a thin JS shim, no WebGL), with a pure rules package that native tests can drive. Toolchain: `/home/yermom/ODIN/odin`.
- **"Push" means `git push`; "ship" means itch.io.** Do neither unless the user says that exact word. Ship at most once a day, through Coxswain (`ship_today` first, `ship_complete` after).
- **New games start at GitHub Pages**, and itch.io is decided afterwards. Making the repo public and enabling Pages are the user's calls; audit for non-redistributable art (1-Bit Kingdom) first. Only the user may opt a game out of Pages.
- On itch.io and in page copy the game is a **"Metaphor"**, never a "Game". Keep the deadpan tone; do not wink at the camera. Do not describe or "fix" deliberate design as a problem.
- Anything an agent posts to itch.io or Ko-fi must say it was posted by an AI agent (Claude Code), and publishing needs a yes each time.
- No Steam work, no marketing, no ad spend.
- If the ROM 8x8 font (`Font8x8.png`) comes up, ask before replacing it (offer DINOBYTE first, then Public Pixel).
- Once the game is real, follow `Tech/Release standard.md` for the repo layout (`ITCH_DESCRIPTION.md`, `assets/cover.png` 630x500, `assets/screenshots/`, `devlog/YYYYMMDD/`, `tools/ship.sh` plus the `shippit.sh` wrapper, `tools/pages.sh`).
