#+build !js
package game

import "core:testing"

new_game :: proc(seed: u64 = 1) -> ^Game {
	g := new(Game)
	game_init(g, seed)
	return g
}

begin :: proc(g: ^Game) {
	game_command(g, .A, true)
}

@(test)
rng_is_deterministic :: proc(t: ^testing.T) {
	a, b: Rng
	rng_seed(&a, 42)
	rng_seed(&b, 42)
	for _ in 0 ..< 100 {
		testing.expect_value(t, rng_next(&a), rng_next(&b))
	}
}

@(test)
every_map_row_is_full_width :: proc(t: ^testing.T) {
	for row in MAP_ROWS {
		testing.expect_value(t, len(row), MAP_WIDTH)
	}
}

@(test)
map_has_one_start_and_the_resident_count :: proc(t: ^testing.T) {
	starts, residents := 0, 0
	for row in MAP_ROWS {
		for ch in row {
			starts += 1 if ch == 'C' else 0
			residents += 1 if ch == 'R' else 0
		}
	}
	testing.expect_value(t, starts, 1)
	testing.expect_value(t, residents, RESIDENT_COUNT)
}

@(test)
every_resident_is_reachable :: proc(t: ^testing.T) {
	g := new_game()
	defer free(g)
	begin(g)
	seen: [MAP_WIDTH * MAP_HEIGHT]bool
	queue: [dynamic][2]int
	defer delete(queue)
	append(&queue, g.cat)
	seen[g.cat.x + g.cat.y * MAP_WIDTH] = true
	for head := 0; head < len(queue); head += 1 {
		p := queue[head]
		for d in ([4][2]int{{0, -1}, {1, 0}, {0, 1}, {-1, 0}}) {
			n := p + d
			if is_wall(n.x, n.y) || seen[n.x + n.y * MAP_WIDTH] {
				continue
			}
			seen[n.x + n.y * MAP_WIDTH] = true
			append(&queue, n)
		}
	}
	for r in g.residents {
		testing.expectf(t, seen[r.pos.x + r.pos.y * MAP_WIDTH], "%s is unreachable", r.name)
	}
}

@(test)
title_waits_for_a :: proc(t: ^testing.T) {
	g := new_game()
	defer free(g)
	game_command(g, .Up, true)
	testing.expect_value(t, g.screen, Screen.Title)
	begin(g)
	testing.expect_value(t, g.screen, Screen.Rounds)
	testing.expect_value(t, g.day, 1)
	testing.expect_value(t, g.energy, ENERGY_MAX)
}

@(test)
walls_block_and_steps_cost_energy :: proc(t: ^testing.T) {
	g := new_game()
	defer free(g)
	begin(g)
	start := g.cat
	// The start is in the corridor, so left is open.
	game_command(g, .Left, true)
	testing.expect_value(t, g.cat, start + {-1, 0})
	testing.expect_value(t, g.energy, ENERGY_MAX - 1)
	for _ in 0 ..< 20 {
		game_command(g, .Left, true)
	}
	before := g.energy
	game_command(g, .Left, true)
	testing.expect_value(t, g.energy, before)
}

@(test)
releasing_a_key_does_nothing :: proc(t: ^testing.T) {
	g := new_game()
	defer free(g)
	begin(g)
	start := g.cat
	game_command(g, .Up, false)
	testing.expect_value(t, g.cat, start)
}

@(test)
stepping_on_a_resident_visits_them :: proc(t: ^testing.T) {
	g := new_game()
	defer free(g)
	begin(g)
	target := g.residents[0].pos
	g.cat = target - {1, 0}
	g.residents[0].visited = false
	game_command(g, .Right, true)
	testing.expect(t, g.residents[0].visited)
	testing.expect(t, len(g.message) > 0)
}

@(test)
running_out_of_energy_ends_the_day :: proc(t: ^testing.T) {
	g := new_game()
	defer free(g)
	begin(g)
	for _ in 0 ..< ENERGY_MAX {
		// Pace the corridor.
		game_command(g, .Right if g.cat.x < 10 else .Left, true)
		if g.screen != .Rounds {
			break
		}
	}
	testing.expect_value(t, g.screen, Screen.Ledger)
}

@(test)
a_run_lasts_the_set_number_of_days :: proc(t: ^testing.T) {
	g := new_game()
	defer free(g)
	begin(g)
	for day in 1 ..= DAYS_PER_RUN {
		testing.expect_value(t, g.day, day)
		game_command(g, .B, true)
		testing.expect_value(t, g.screen, Screen.Ledger)
		game_command(g, .A, true)
	}
	testing.expect_value(t, g.screen, Screen.Title)
}

@(test)
frames_draw_something_on_every_screen :: proc(t: ^testing.T) {
	g := new_game()
	defer free(g)
	for _ in 0 ..< 3 {
		game_frame(g, 0.016)
		lit := 0
		for p in g.canvas.pixels {
			lit += 1 if p != .Night else 0
		}
		testing.expectf(t, lit > 100, "%v drew %d pixels", g.screen, lit)
		if g.screen == .Title {
			begin(g)
		} else {
			game_command(g, .B, true)
		}
	}
}

@(test)
fuzz_random_commands_never_break_invariants :: proc(t: ^testing.T) {
	for seed in 0 ..< u64(40) {
		g := new_game(seed)
	defer free(g)
		r: Rng
		rng_seed(&r, seed + 1000)
		for step in 0 ..< 2000 {
			game_command(g, Command(rng_below(&r, len(Command))), true)
			if step % 50 == 0 {
				game_frame(g, 0.016)
			}
			testing.expect(t, g.energy >= 0 && g.energy <= ENERGY_MAX)
			testing.expect(t, !is_wall(g.cat.x, g.cat.y) || g.screen == .Title)
			testing.expect(t, g.day >= 0 && g.day <= DAYS_PER_RUN)
		}
	}
}
