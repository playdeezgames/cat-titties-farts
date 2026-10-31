package game

import "core:fmt"

draw_title :: proc(g: ^Game) {
	c := &g.canvas
	draw_text_centered(c, 52, "NURSING HOME CAT", .Cream, 3)
	draw_text_centered(c, 84, "of SPLORR!!", .Gold, 2)
	draw_text_centered(c, 108, "home of the TITTIES", .Rose)
	if g.saved {
		buf: [64]u8
		draw_text_centered(c, 128, fmt.bprintf(buf[:], "A: continue day %d (the day starts over)", g.save.day), .Gray)
		draw_text_centered(c, 140, "B: new run", .Gray)
	} else {
		draw_text_centered(c, 134, "Press A to begin the rounds", .Gray)
	}
	draw_text_centered(c, 158, "DINOBYTE font by mby, CC BY 4.0", .Wall)
	draw_text_centered(c, 168, "Urizen tiles by vurmux, CC0", .Wall)
}

tile_for :: proc(ch: u8) -> (tile: Tile, hue: Hue, ok: bool) {
	switch ch {
	case 'b':
		return .Bed, .Wood, true
	case 'c':
		return .Chair, .Wood, true
	case 't':
		return .Table, .Wood, true
	case 's':
		return .Sofa, .Plum, true
	case 'k':
		return .Shelf, .Wood, true
	case 'p':
		return .Plant, .Leaf, true
	}
	return {}, {}, false
}

// The TITTIES hall is the wide room in the top row; its sign hangs in the wall above it.
HALL_FIRST_COLUMN :: 12
HALL_COLUMNS :: 8

draw_rounds :: proc(g: ^Game) {
	c := &g.canvas
	for row, y in MAP_ROWS {
		for x in 0 ..< MAP_WIDTH {
			px, py := x * TILE, MAP_TOP + y * TILE
			if row[x] == '#' {
				canvas_fill(c, px, py, TILE, TILE, .Wall)
				draw_tile(c, px, py, .Wall, .Brick)
				continue
			}
			canvas_fill(c, px, py, TILE, TILE, .Floor)
			if tile, hue, ok := tile_for(row[x]); ok {
				draw_tile(c, px, py, tile, hue)
			}
		}
	}
	sign := "TITTIES"
	canvas_fill(c, HALL_FIRST_COLUMN * TILE, MAP_TOP, HALL_COLUMNS * TILE, TILE, .Night)
	draw_text(c, (HALL_FIRST_COLUMN + HALL_COLUMNS / 2) * TILE - text_width(sign) / 2, MAP_TOP + 2, sign, .Gold)
	for r in g.residents {
		hue := Hue.Leaf if r.visited else (Hue.Teal if r.member else Hue.Plum)
		draw_tile(c, r.pos.x * TILE, MAP_TOP + r.pos.y * TILE, .Person, hue)
	}
	draw_tile(c, g.cat.x * TILE, MAP_TOP + g.cat.y * TILE, .Cat, .Cat)

	buf: [64]u8
	header := fmt.bprintf(buf[:], "Day %d of %d  Energy %d  Purr %d", g.day, DAYS_PER_RUN, g.energy, g.purr)
	draw_text(c, 2, 0, header, .Cream)
	if energy_spent(g) < MEETING_END {
		draw_text(c, VIEW_WIDTH - text_width("TITTIES in session") - 2, 0, "TITTIES in session", .Gold)
	}
	if g.offering {
		draw_offer_menu(g)
	}
	// A long result (a visit plus a fart) wraps onto the row just under the map instead of running off the screen.
	message := g.message if g.message != "" else "Walk into a resident to visit.  A: help"
	message_lines: [2]string
	line_count := wrap_text(message, VIEW_WIDTH / FONT_WIDTH, message_lines[:])
	for i in 0 ..< min(line_count, len(message_lines)) {
		draw_text_centered(c, VIEW_HEIGHT - FONT_HEIGHT * (min(line_count, len(message_lines)) - i), message_lines[i], .Gold)
	}
	if g.confirming_nap {
		draw_box(c, 56, 64, 208, 40)
		draw_text_centered(c, 72, "Nap now and end the day?", .Cream)
		draw_text_centered(c, 88, "A: nap    B: keep going", .Gold)
	}
	if g.help_page > 0 {
		draw_help(g)
	}
}

draw_hearts :: proc(c: ^Canvas, x, y, mood: int) {
	for i in 0 ..< MOOD_MAX {
		draw_char(c, x + i * FONT_WIDTH, y, 3, .Rose if i < mood else .Wall)
	}
}

draw_offer_menu :: proc(g: ^Game) {
	c := &g.canvas
	r := g.residents[g.target]
	canvas_fill(c, 36, 40, 248, 96, .Cream)
	canvas_fill(c, 38, 42, 244, 92, .Night)
	buf: [96]u8
	line := fmt.bprintf(buf[:], "%s: %s.", r.name, WANT_HINT[r.want])
	draw_text(c, 46, 48, line, .Cream)
	draw_hearts(c, 46, 60, r.mood)
	if r.member && energy_spent(g) < MEETING_END {
		draw_text(c, 100, 60, "TITTIES meeting: double purr", .Gold)
	}
	for want in Want {
		y := 74 + int(want) * 11
		hue := Hue.Gold if want == g.cursor else Hue.Gray
		cost := fmt.bprintf(buf[:], "%s (%d)", OFFER_TEXT[want], OFFER_COST[want])
		draw_text(c, 46, y, ">" if want == g.cursor else " ", hue)
		draw_text(c, 58, y, cost, hue)
	}
	draw_text(c, 46, 122, "A offers, B steps back", .Gray)
}

draw_ledger :: proc(g: ^Game) {
	c := &g.canvas
	draw_text_centered(c, 6, "The day is over", .Cream, 2)
	for r, i in g.residents {
		buf: [96]u8
		line := fmt.bprintf(buf[:], "%s: %s", r.name, "visited" if r.visited else "not visited")
		y := 34 + i * 14
		draw_text(c, 24, y, line, .Sage if r.visited else .Gray)
		draw_hearts(c, 250, y, r.mood)
	}
	buf: [64]u8
	members_seen := 0
	for r in g.residents {
		members_seen += 1 if r.member && r.visited else 0
	}
	attendance := fmt.bprintf(buf[:], "TITTIES attendance: %d of %d members", members_seen, MEMBER_COUNT)
	draw_text_centered(c, 128, attendance, .Rose)
	total: string
	if g.day >= DAYS_PER_RUN {
		total = fmt.bprintf(buf[:], "TITTIES annual report: %d member visits, %d purr", g.member_visits, g.purr)
	} else {
		total = fmt.bprintf(buf[:], "Day %d of %d  Purr %d", g.day, DAYS_PER_RUN, g.purr)
	}
	draw_text_centered(c, 154, MINUTES[clamp(g.day, 1, DAYS_PER_RUN) - 1], .Cream)
	draw_text_centered(c, 142, total, .Gold)
	draw_text_centered(c, VIEW_HEIGHT - FONT_HEIGHT, "Press A", .Gold)
}

draw_box :: proc(c: ^Canvas, x, y, w, h: int) {
	canvas_fill(c, x - 2, y - 2, w + 4, h + 4, .Cream)
	canvas_fill(c, x, y, w, h, .Night)
}

// Breaks text into lines of at most `width` characters at spaces; "\n" forces a break. Returns the line count.
// Lines are slices of text, so nothing is copied.
wrap_text :: proc(text: string, width: int, lines: []string) -> int {
	count := 0
	start := 0
	for start < len(text) && count < len(lines) {
		end := start
		last_space := -1
		for end < len(text) && end - start < width && text[end] != '\n' {
			if text[end] == ' ' {
				last_space = end
			}
			end += 1
		}
		next := end
		if end < len(text) && text[end] != '\n' && last_space >= 0 {
			end = last_space
			next = last_space + 1
		} else if end < len(text) && text[end] == '\n' {
			next = end + 1
		}
		lines[count] = text[start:end]
		count += 1
		start = next
	}
	return count
}

HELP_WIDTH :: 46
HELP_LINES :: 14

draw_help :: proc(g: ^Game) {
	c := &g.canvas
	canvas_clear(c, .Night)
	draw_box(c, 8, 6, VIEW_WIDTH - 16, VIEW_HEIGHT - 12)
	buf: [64]u8
	title := fmt.bprintf(buf[:], "HOW TO PLAY  %d/%d: %s", g.help_page, HELP_PAGES, HELP_TITLES[g.help_page - 1])
	draw_text_centered(c, 12, title, .Gold)
	lines: [HELP_LINES]string
	n := wrap_text(HELP_TEXT[g.help_page - 1], HELP_WIDTH, lines[:])
	for i in 0 ..< n {
		draw_text(c, 20, 28 + i * 10, lines[i], .Cream)
	}
	more := "A: next page    B: close" if g.help_page < HELP_PAGES else "A: close    B: close"
	draw_text_centered(c, VIEW_HEIGHT - 20, more, .Gray)
}
