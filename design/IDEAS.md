# Ideas to iterate on

Seeds: **cats**, **titties**, **farts**. Drafted October 30, 2026 by `ctf`. Nothing here is chosen; the user picks, merges or kills. Each idea is a Metaphor: a mundane thing gamified, deadpan copy, small retro presentation, a mechanic that is the message.

## 1. Cat Gas Station of SPLORR!!
A cat has eaten something it should not have. You are the only one home. Every few turns the cat lets one go; you can open windows, light candles or leave the room, and each costs time. The cat's face tells you the next one is coming. Mechanic is the message: you cannot stop it, only manage it. Clock: the in-laws arrive at six.
- Scope: one apartment, 6 rooms, grid movement. Anvil: cat, candle, window, gas cloud tiles. Sounds are the whole joke.
- Closest to: [[Roomba Rights]] (a thing on a route), [[Robokitteh]].

## 2. Nursing Home Cat
A therapy cat makes rounds. Residents (the "titties" seed, read as the Nursing Home's affectionate nickname for the cat's favourite, the soft-chested ones: pillows, cardigans, bosoms of old women in knitwear) each want a lap. Pick whose lap, in what order, before the cat's nap timer runs out. Gentle, sincere, a little sad. Farts exist as a consequence of the lap food.
- Risk: the tone can slide from tender to crude; decide which on purpose.

## 3. Titmouse (the bird)
A pun the seed allows: a **tit** is a bird. Platform-free bird-watching: a titmouse, a tit and a booby on a feeder while a cat stalks the garden. Photograph the birds in the right order; the cat wins if you are loud. Pure wordplay on "titties", fully clean, the pun is the point. Farts are the loud thing that scares the birds.
- Scope: one garden, a camera frame, a stalking cat on a hidden route (watch it, cannot change it).

## 4. Fart Cat Roguelike (T!ts UUp!! sibling)
Single room, a handful of enemies, a cat whose only attack is the fart. Dice like T!ts UUp!! (`1d6/6`). Wind direction matters; enemies upwind are fine. One-room, 9 by 9, a locked door. "The way out is a locked door; you could also just win by killing everything." Uses the existing port's architecture and rules style.
- Fastest to build: copy the proven T!ts UUp!! structure (pure `game` package, framebuffer, native tests).

## 5. Weight of the Lap (idle clicker)
Check Yer Butthole's cousin. A cat sits on you. Each minute of real time it gets heavier and warmer; you buy a blanket, a mug, a remote you cannot reach. Moving makes it leave, which ends the run. Idle mechanic where doing nothing is the skill. Farts and titties become flavour on the upgrade list (a "chest" shelf for the cat; a gas that makes it jump).
- Closest to: [[Check Yer Butthole]], [[Starvation]] (draining resource as clock).

## 6. Meowch Potato
A day in a dating app for cats: swipe profiles with deliberately awful photos. The seed words are the profile tags that decide matches (cat, tits, farts: each profile has one hidden trait). Short, text-heavy, 1-bit. A match unlocks nothing.

## How I would pick

Quick prototypes first: #4 (reuses a working architecture) and #1 (clearest mechanic that is the message). #3 is the cleanest if the user wants something public and tidy. Ask the user which tone they want before building: crude (#1, #4), tender (#2), clean pun (#3).
