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

by_name :: proc(g: ^Game, name: string) -> int {
	for r, i in g.residents {
		if r.name == name {
			return i
		}
	}
	return -1
}

@(test)
map_has_one_start_and_the_resident_count :: proc(t: ^testing.T) {
	starts, residents := 0, 0
	for row in MAP_ROWS {
		for ch in row {
			starts += 1 if ch == 'C' else 0
			residents += 1 if ch == 'R' || ch == 'M' else 0
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

// Puts the cat beside resident i, inside their window, with a known want.
stand_beside :: proc(g: ^Game, i: int, want: Want, spent := 0) {
	g.residents[i].want = want
	g.energy = ENERGY_MAX - spent
	g.cat = g.residents[i].pos - {1, 0}
}

@(test)
members_are_the_ones_in_the_hall :: proc(t: ^testing.T) {
	g := new_game()
	defer free(g)
	begin(g)
	for r in g.residents {
		in_hall := r.pos.x >= HALL_FIRST_COLUMN && r.pos.x < HALL_FIRST_COLUMN + HALL_COLUMNS && r.pos.y < 4
		testing.expectf(t, r.member == in_hall, "%s", r.name)
	}
}

@(test)
bumping_a_resident_opens_the_menu_for_free :: proc(t: ^testing.T) {
	g := new_game()
	defer free(g)
	begin(g)
	stand_beside(g, by_name(g, "Dolores"), .Lap)
	start := g.cat
	game_command(g, .Right, true)
	testing.expect(t, g.offering)
	testing.expect_value(t, g.target, by_name(g, "Dolores"))
	testing.expect_value(t, g.cat, start)
	testing.expect_value(t, g.energy, ENERGY_MAX)
}

@(test)
matching_the_want_pleases_and_earns_purr :: proc(t: ^testing.T) {
	g := new_game()
	defer free(g)
	begin(g)
	stand_beside(g, by_name(g, "Walter"), .Story, 10) // Walter is not a member
	game_command(g, .Right, true)
	for g.cursor != .Story {
		game_command(g, .Down, true)
	}
	game_command(g, .A, true)
	testing.expect_value(t, g.residents[by_name(g, "Walter")].mood, MOOD_START + 2)
	testing.expect_value(t, g.purr, PURR_MATCH)
	testing.expect_value(t, g.energy, ENERGY_MAX - 10 - OFFER_COST[.Story])
	testing.expect(t, g.residents[by_name(g, "Walter")].visited)
	testing.expect(t, !g.offering)
}

@(test)
a_mismatch_hurts_and_costs_extra :: proc(t: ^testing.T) {
	g := new_game()
	defer free(g)
	begin(g)
	stand_beside(g, by_name(g, "Walter"), .Story, 10)
	game_command(g, .Right, true)
	g.cursor = .Treat
	game_command(g, .A, true)
	testing.expect_value(t, g.residents[by_name(g, "Walter")].mood, MOOD_START - 1)
	testing.expect_value(t, g.purr, 0)
	testing.expect_value(t, g.energy, ENERGY_MAX - 10 - OFFER_COST[.Treat] - MISMATCH_EXTRA_COST)
}

@(test)
members_earn_double_purr_at_the_meeting :: proc(t: ^testing.T) {
	g := new_game()
	defer free(g)
	begin(g)
	stand_beside(g, by_name(g, "Dolores"), .Lap) // Dolores is a member
	game_command(g, .Right, true)
	g.cursor = .Lap
	game_command(g, .A, true)
	testing.expect_value(t, g.purr, PURR_MATCH * 2)
}

@(test)
member_visits_are_counted_for_the_annual_report :: proc(t: ^testing.T) {
	g := new_game()
	defer free(g)
	begin(g)
	stand_beside(g, by_name(g, "Dolores"), .Lap)
	game_command(g, .Right, true)
	game_command(g, .A, true)
	testing.expect_value(t, g.member_visits, 1)
	stand_beside(g, by_name(g, "Walter"), .Lap, 10)
	game_command(g, .Right, true)
	game_command(g, .A, true)
	testing.expect_value(t, g.member_visits, 1)
}

@(test)
every_ledger_line_fits_the_screen :: proc(t: ^testing.T) {
	for line in MINUTES {
		testing.expectf(t, text_width(line) <= VIEW_WIDTH, "%s", line)
	}
	testing.expect(t, text_width("TITTIES annual report: 99 member visits, 9999 purr") <= VIEW_WIDTH)
}

has_sfx :: proc(g: ^Game, sfx: Sfx) -> bool {
	for i in 0 ..< g.sfx_count {
		if g.sfx[i] == sfx {
			return true
		}
	}
	return false
}

@(test)
sounds_follow_the_events :: proc(t: ^testing.T) {
	g := new_game()
	defer free(g)
	begin(g)
	testing.expect(t, has_sfx(g, .Bell))
	g.sfx_count = 0
	stand_beside(g, by_name(g, "Walter"), .Story, 10)
	game_command(g, .Right, true)
	testing.expect(t, has_sfx(g, .Blip))
	g.cursor = .Story
	game_command(g, .A, true)
	testing.expect(t, has_sfx(g, .Content))
	testing.expect(t, !has_sfx(g, .Fart))
	g.sfx_count = 0
	game_command(g, .B, true)
	testing.expect(t, has_sfx(g, .Day_End))
}

@(test)
only_lap_visits_ever_fart :: proc(t: ^testing.T) {
	farts_on_lap, farts_on_story := 0, 0
	for seed in 0 ..< u64(60) {
		for want in ([2]Want{.Lap, .Story}) {
			g := new_game(seed)
			begin(g)
			stand_beside(g, by_name(g, "Walter"), want, 10)
			game_command(g, .Right, true)
			g.cursor = want
			game_command(g, .A, true)
			if has_sfx(g, .Fart) {
				if want == .Lap {
					farts_on_lap += 1
				} else {
					farts_on_story += 1
				}
			}
			free(g)
		}
	}
	testing.expect(t, farts_on_lap > 0 && farts_on_lap < 60)
	testing.expect_value(t, farts_on_story, 0)
}

@(test)
a_fart_only_bothers_someone_who_wanted_quiet :: proc(t: ^testing.T) {
	for seed in 0 ..< u64(200) {
		g := new_game(seed)
		begin(g)
		w := by_name(g, "Walter")
		stand_beside(g, w, .Lap, 10)
		game_command(g, .Right, true)
		g.cursor = .Lap
		game_command(g, .A, true)
		testing.expect_value(t, g.residents[w].mood, MOOD_START + 2) // matched; the want is a lap, so no one minds
		free(g)
	}
}

@(test)
someone_who_wanted_quiet_minds_the_fart :: proc(t: ^testing.T) {
	minded := 0
	for seed in 0 ..< u64(200) {
		g := new_game(seed)
		begin(g)
		w := by_name(g, "Walter")
		stand_beside(g, w, .Quiet, 10)
		game_command(g, .Right, true)
		g.cursor = .Lap // a mismatch: -1 mood
		game_command(g, .A, true)
		if has_sfx(g, .Fart) {
			minded += 1
			testing.expect_value(t, g.residents[w].mood, MOOD_START - 2)
		} else {
			testing.expect_value(t, g.residents[w].mood, MOOD_START - 1)
		}
		free(g)
	}
	testing.expect(t, minded > 0)
}

@(test)
nobody_is_visited_outside_their_window :: proc(t: ^testing.T) {
	g := new_game()
	defer free(g)
	begin(g)
	stand_beside(g, by_name(g, "Mr. Lindqvist"), .Lap, 0) // Mr. Lindqvist opens at 20
	game_command(g, .Right, true)
	testing.expect(t, !g.offering)
	g.energy = ENERGY_MAX - 60 + 1
	g.cat = g.residents[by_name(g, "Dolores")].pos - {1, 0} // Dolores closes at 30
	game_command(g, .Right, true)
	testing.expect(t, !g.offering)
}

@(test)
a_resident_is_visited_once_a_day :: proc(t: ^testing.T) {
	g := new_game()
	defer free(g)
	begin(g)
	stand_beside(g, by_name(g, "Walter"), .Lap, 10)
	game_command(g, .Right, true)
	game_command(g, .A, true)
	game_command(g, .Right, true)
	testing.expect(t, !g.offering)
}

@(test)
backing_out_of_the_menu_changes_nothing :: proc(t: ^testing.T) {
	g := new_game()
	defer free(g)
	begin(g)
	stand_beside(g, by_name(g, "Walter"), .Lap, 10)
	game_command(g, .Right, true)
	game_command(g, .B, true)
	testing.expect(t, !g.offering)
	testing.expect(t, !g.residents[by_name(g, "Walter")].visited)
	testing.expect_value(t, g.energy, ENERGY_MAX - 10)
}

@(test)
the_unvisited_are_quieter_tomorrow :: proc(t: ^testing.T) {
	g := new_game()
	defer free(g)
	begin(g)
	stand_beside(g, by_name(g, "Walter"), .Lap, 10)
	game_command(g, .Right, true)
	g.cursor = .Lap
	game_command(g, .A, true)
	visited_mood := g.residents[by_name(g, "Walter")].mood
	game_command(g, .B, true)
	testing.expect_value(t, g.residents[by_name(g, "Walter")].mood, visited_mood)
	testing.expect_value(t, g.residents[by_name(g, "Dolores")].mood, MOOD_START - 1)
	game_command(g, .A, true)
	testing.expect_value(t, g.day, 2)
	testing.expect(t, !g.residents[by_name(g, "Walter")].visited)
	testing.expect_value(t, g.residents[by_name(g, "Dolores")].mood, MOOD_START - 1)
}

@(test)
a_visit_that_costs_more_than_is_left_ends_the_day :: proc(t: ^testing.T) {
	g := new_game()
	defer free(g)
	begin(g)
	stand_beside(g, by_name(g, "Mr. Lindqvist"), .Lap, 58) // Mr. Lindqvist is receiving until 60; 2 energy left
	game_command(g, .Right, true)
	g.cursor = .Lap
	game_command(g, .A, true)
	testing.expect_value(t, g.screen, Screen.Ledger)
	testing.expect_value(t, g.energy, 0)
	testing.expect_value(t, g.purr, PURR_MATCH)
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
			testing.expect(t, g.purr >= 0)
			testing.expect(t, g.day >= 0 && g.day <= DAYS_PER_RUN)
			for r in g.residents {
				testing.expect(t, r.mood >= 0 && r.mood <= MOOD_MAX)
			}
		}
	}
}
