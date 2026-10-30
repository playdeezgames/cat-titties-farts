package game

import "core:fmt"

game_init :: proc(g: ^Game, seed: u64) {
	g^ = {}
	rng_seed(&g.rng, seed)
	g.screen = .Title
}

play :: proc(g: ^Game, sfx: Sfx) {
	if g.sfx_count < len(g.sfx) {
		g.sfx[g.sfx_count] = sfx
		g.sfx_count += 1
	}
}

set_message :: proc(g: ^Game, format: string, args: ..any) {
	g.message = fmt.bprintf(g.message_buf[:], format, ..args)
}

// A run is DAYS_PER_RUN days; moods carry across days, so the residents are set up once here.
new_run :: proc(g: ^Game) {
	g.day = 1
	g.purr = 0
	g.member_visits = 0
	index, members, others := 0, 0, 0
	for row, y in MAP_ROWS {
		for ch, x in row {
			if ch != 'R' && ch != 'M' {
				continue
			}
			r := Resident {
				pos  = {x, y},
				mood = MOOD_START,
			}
			if ch == 'M' {
				r.member = true
				r.name = MEMBER_NAMES[members]
				r.window = {0, MEETING_END}
				members += 1
			} else {
				r.name = OTHER_NAMES[others]
				r.window = OTHER_WINDOWS[others]
				others += 1
			}
			g.residents[index] = r
			index += 1
		}
	}
	start_day(g)
}

start_day :: proc(g: ^Game) {
	g.screen = .Rounds
	g.energy = ENERGY_MAX
	set_message(g, "TITTIES meets in the hall until %d energy is spent.", MEETING_END)
	play(g, .Bell)
	g.offering = false
	for row, y in MAP_ROWS {
		for ch, x in row {
			if ch == 'C' {
				g.cat = {x, y}
			}
		}
	}
	for &r in g.residents {
		r.want = Want(rng_below(&g.rng, len(Want)))
		r.visited = false
	}
}

// Anyone left unvisited is a little quieter tomorrow.
end_day :: proc(g: ^Game) {
	g.offering = false
	g.energy = max(g.energy, 0)
	play(g, .Day_End)
	for &r in g.residents {
		if !r.visited {
			r.mood = max(r.mood - 1, 0)
		}
	}
	g.screen = .Ledger
}

energy_spent :: proc(g: ^Game) -> int {
	return ENERGY_MAX - g.energy
}

resident_at :: proc(g: ^Game, x, y: int) -> int {
	for r, i in g.residents {
		if r.pos == {x, y} {
			return i
		}
	}
	return -1
}

visited_count :: proc(g: ^Game) -> int {
	n := 0
	for r in g.residents {
		if r.visited {
			n += 1
		}
	}
	return n
}

// Bumping a resident opens the offer menu, if they are receiving; it costs no energy.
bump :: proc(g: ^Game, i: int) {
	r := &g.residents[i]
	spent := energy_spent(g)
	window := r.window
	switch {
	case r.visited:
		set_message(g, "%s has had a visit today.", r.name)
		play(g, .Bump)
	case spent < window[0]:
		set_message(g, "%s is not receiving yet.", r.name)
		play(g, .Bump)
	case spent >= window[1]:
		set_message(g, "%s is no longer receiving.", r.name)
		play(g, .Bump)
	case:
		play(g, .Blip)
		g.offering = true
		g.target = i
		g.cursor = .Lap
		g.message = ""
	}
}

make_offer :: proc(g: ^Game) {
	r := &g.residents[g.target]
	meeting := r.member && energy_spent(g) < MEETING_END
	cost := OFFER_COST[g.cursor]
	g.offering = false
	r.visited = true
	if r.member {
		g.member_visits += 1
	}
	if g.cursor == r.want {
		r.mood = min(r.mood + 2, MOOD_MAX)
		gain := PURR_MATCH * 2 if meeting else PURR_MATCH
		g.purr += gain
		play(g, .Purr if g.cursor == .Lap else .Content)
		if meeting {
			set_message(g, "TITTIES meeting! %s is content. +%d purr.", r.name, gain)
		} else {
			set_message(g, "%s is content. +%d purr.", r.name, gain)
		}
	} else {
		r.mood = max(r.mood - 1, 0)
		cost += MISMATCH_EXTRA_COST
		set_message(g, "%s wanted %s.", r.name, WANT_TEXT[r.want])
		play(g, .Wrong)
	}
	// Nerves: a lap visit sometimes ends in a fart. Only someone who wanted quiet minds.
	if g.cursor == .Lap && rng_below(&g.rng, FART_ODDS) == 0 {
		prior_buf: [96]u8
		n := copy(prior_buf[:], g.message)
		play(g, .Fart)
		if r.want == .Quiet {
			r.mood = max(r.mood - 1, 0)
			set_message(g, "%s The cat farts. %s minds.", string(prior_buf[:n]), r.name)
		} else {
			set_message(g, "%s The cat farts. Nobody minds.", string(prior_buf[:n]))
		}
	}
	g.energy -= cost
	if g.energy <= 0 {
		end_day(g)
	}
}

try_move :: proc(g: ^Game, dx, dy: int) {
	nx, ny := g.cat.x + dx, g.cat.y + dy
	if is_wall(nx, ny) {
		return
	}
	if i := resident_at(g, nx, ny); i >= 0 {
		bump(g, i)
		return
	}
	g.cat = {nx, ny}
	g.energy -= 1
	g.message = ""
	if g.energy <= 0 {
		end_day(g)
	}
}

offer_command :: proc(g: ^Game, command: Command) {
	count := len(Want)
	#partial switch command {
	case .Up:
		g.cursor = Want((int(g.cursor) + count - 1) % count)
		play(g, .Blip)
	case .Down:
		g.cursor = Want((int(g.cursor) + 1) % count)
		play(g, .Blip)
	case .A:
		make_offer(g)
	case .B:
		g.offering = false
	}
}

game_command :: proc(g: ^Game, command: Command, down: bool) {
	if !down {
		return
	}
	switch g.screen {
	case .Title:
		if command == .A {
			new_run(g)
		}
	case .Rounds:
		if g.offering {
			offer_command(g, command)
			return
		}
		switch command {
		case .Up:
			try_move(g, 0, -1)
		case .Right:
			try_move(g, 1, 0)
		case .Down:
			try_move(g, 0, 1)
		case .Left:
			try_move(g, -1, 0)
		case .B:
			end_day(g)
		case .A:
		}
	case .Ledger:
		if command == .A {
			if g.day >= DAYS_PER_RUN {
				g.screen = .Title
			} else {
				g.day += 1
				start_day(g)
			}
		}
	}
}

game_frame :: proc(g: ^Game, dt: f64) {
	c := &g.canvas
	canvas_clear(c, .Night)
	switch g.screen {
	case .Title:
		draw_title(g)
	case .Rounds:
		draw_rounds(g)
	case .Ledger:
		draw_ledger(g)
	}
	canvas_to_rgba(c, &g.pixels)
}
