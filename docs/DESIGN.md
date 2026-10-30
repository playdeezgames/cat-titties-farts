# Nursing Home Cat: design (draft 1)

Chosen by the user on October 30, 2026 from `docs/IDEAS.md` (idea 2). Working title: **Nursing Home Cat of SPLORR!!**. Everything below is a proposal for the user to correct.

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

## Status

Scaffold built October 30, 2026: title, a movable cat on the care-home floor, seven residents who say what they want, energy, a ledger, 12 native tests, a wasm build that runs in the browser. Wants, moods, visit windows and the TITTIES meeting are not implemented yet (Coxswain task 345).
