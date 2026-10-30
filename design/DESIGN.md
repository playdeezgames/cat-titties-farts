# Nursing Home Cat: design (draft 1)

Chosen by the user on October 30, 2026 from `design/IDEAS.md` (idea 2). Working title: **Nursing Home Cat of SPLORR!!**. Everything below is a proposal for the user to correct.

## Premise

A therapy cat makes its afternoon rounds at a care home. Each resident wants a lap visit. The cat has a nap timer; when it runs out, the day is over. The mechanic is the message: you cannot visit everyone, and who you choose is the whole game. Tone is sincere and deadpan, a little sad, never mocking the residents. Copy is plain and short.

## The seeds, handled

- **Cats**: the player is the cat.
- **Titties**: a running joke, on the residents' side and never the cat's. The residents' knitting circle is the **Tuesday Indoor Tatting & Tea Interest Exchange Society**, TITTIES for short, and they use the acronym with total sincerity on signs, sign-up sheets and the bingo board. The only person who finds it funny is the new night nurse. The cat attends the meetings (a lap visit with extra yarn). Non-sexual throughout; the joke is how earnestly they say it.
- **Farts**: lap food and nerves. The cat sometimes lets one go; residents mostly do not mind, a few do. It is a consequence, not the objective.

## Core loop (turn-based, grid)

1. One floor of the home: a corridor, a lounge, a garden door, 8 to 10 rooms. Grid movement; each step costs energy.
2. Each resident has: a **mood**, a **want** (warm lap, quiet, a story, a treat, to be left alone) and a **visiting window** (meals, bingo, sleep).
3. Entering a room offers Visit / Pass. A visit that matches the want raises their mood and refills the cat's **purr** (score); a mismatch costs mood and energy.
4. Energy is the clock (see Starvation in the bok): it drains per step and per visit, and naps in a sunny spot restore some but spend the window of the next visit.
5. The day ends at the nap timer. The epilogue lists everyone you visited and everyone you did not, one line each. No winning, just a ledger.

## Mechanics that carry the metaphor

- Visits are exclusive: two residents' windows overlap, so someone is always missed.
- A resident you skipped says nothing; the next day they are quieter. Days persist (a short run of days, saved in localStorage).
- Residents come and go between days; the ledger notes it flatly.

## Technical plan

- Odin, `js_wasm32`, per the bok's Odin wasm recipe; pure `game` package, framebuffer, native tests via `tools/test.sh` (model on T!ts UUp!!).
- Art and sound from the Anvil: cat, residents, furniture, tiles; soft chimes and purr. Palette warm and limited.
- GitHub Pages first; itch.io undecided.

## Decisions (the user's, October 30, 2026)

- "Titties" seed: a running joke, as above.
- Days per run, resolution and font were left to defaults: **5 days**, **320 by 180**, **DINOBYTE** (credit on the title screen).

## Art (October 30, 2026)

Urizen 1-bit tiles by vurmux (CC0) for walls, floor, furniture, the cat (1,14) and people (104,0), one hue each. The map is 26 by 13 tiles of 12 px. More TITTIES, at the user's request: the hall in the top row is the society's meeting room with its sign over the door, the three members (gold) are in it, the header says "TITTIES in session" while the meeting runs, the ledger reports member attendance and carries the secretary's minutes (one deadpan line per day, the night nurse always in them), and day 5 ends with the TITTIES annual report. Floor is plain and objects use dark hues (plum, leaf green, teal for members) so they read against the tan.

## Sound (October 30, 2026)

Eight square-wave sounds made in the Anvil (`assets/anvil/world.json` holds the PLAY text; WAVs in `assets/sfx/`): purr (a matched lap), content (any other match), wrong, bell (the TITTIES meeting opens each day), blip (menu), bump (someone not receiving), day_end and fart. The farts are in the game now: one lap visit in four ends in one, and only a resident who wanted quiet minds (-1 mood).

## Saves (October 30, 2026)

The run is saved to localStorage (`nhc:run`, one line of text) at the start of every day: day, purr, member visits, the RNG state, every resident's mood and want. The title offers "A: continue day N (the day starts over)" and "B: new run". Finishing day 5 clears the save. A damaged or out-of-range save is refused and the game starts clean. Mid-day state is deliberately not saved: continuing restarts the day with the same wants and full energy.

## Playtest feedback and onboarding (October 30, 2026)

First blind playtests: "What the fuck is happening?!", "this one MIGHT need a booklet", "this shit needs a novel, not a booklet"; the user could not tell what to do either. Response: a five-page how-to-play booklet (the job, visiting, when residents receive, the TITTIES, keys) that opens by itself on a browser's first run and from A while walking; closed residents now say at what energy they open or closed; B asks before napping (it ends the day); the bottom line says "A: help". The booklet is the minimum; the game still teaches little by itself (see open question: a guided first day).

## Status

October 30, 2026: scaffold plus core visit rules (task 345). Walking into a resident opens an offer menu (lap 6, quiet 2, story 5, treat 4 energy); a hint line gives their want away ("holding a book"). A match is +2 mood and 10 purr, a mismatch is -1 mood and 3 extra energy. Each resident has a window of energy spent when they receive visitors; members of TITTIES meet until 30 spent and pay double purr. Anyone unvisited is one mood quieter next day; moods carry across the 5-day run. 20 native tests. Not built: saves, sound, Anvil art, the garden door and lounge, residents coming and going, a final run summary.
