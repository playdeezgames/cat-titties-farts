package game

import "core:fmt"

game_init :: proc(g: ^Game, seed: u64) {
	g^ = {}
	rng_seed(&g.rng, seed)
	g.screen = .Title
}

set_message :: proc(g: ^Game, format: string, args: ..any) {
	g.message = fmt.bprintf(g.message_buf[:], format, ..args)
}

start_day :: proc(g: ^Game) {
	g.screen = .Rounds
	g.energy = ENERGY_MAX
	g.message = ""
	index := 0
	for row, y in MAP_ROWS {
		for ch, x in row {
			switch ch {
			case 'C':
				g.cat = {x, y}
			case 'R':
				g.residents[index] = Resident {
					pos  = {x, y},
					name = RESIDENT_NAMES[index],
					want = Want(rng_below(&g.rng, len(Want))),
				}
				index += 1
			}
		}
	}
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

try_move :: proc(g: ^Game, dx, dy: int) {
	nx, ny := g.cat.x + dx, g.cat.y + dy
	if is_wall(nx, ny) {
		return
	}
	g.cat = {nx, ny}
	g.energy -= 1
	g.message = ""
	if i := resident_at(g, nx, ny); i >= 0 {
		g.residents[i].visited = true
		set_message(g, "%s wants %s.", g.residents[i].name, WANT_TEXT[g.residents[i].want])
	}
	if g.energy <= 0 {
		g.screen = .Ledger
	}
}

game_command :: proc(g: ^Game, command: Command, down: bool) {
	if !down {
		return
	}
	switch g.screen {
	case .Title:
		if command == .A {
			g.day = 1
			start_day(g)
		}
	case .Rounds:
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
			g.screen = .Ledger
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
