package game

import "core:fmt"

draw_title :: proc(g: ^Game) {
	c := &g.canvas
	draw_text_centered(c, 52, "NURSING HOME CAT", .Cream, 3)
	draw_text_centered(c, 84, "of SPLORR!!", .Gold, 2)
	draw_text_centered(c, 130, "Press A to begin the rounds", .Gray)
	draw_text_centered(c, 166, "DINOBYTE font by mby, CC BY 4.0", .Wall)
}

draw_rounds :: proc(g: ^Game) {
	c := &g.canvas
	for row, y in MAP_ROWS {
		for x in 0 ..< MAP_WIDTH {
			hue := Hue.Wall if row[x] == '#' else Hue.Floor
			canvas_fill(c, x * TILE, MAP_TOP + y * TILE, TILE, TILE, hue)
		}
	}
	for r in g.residents {
		draw_char(c, r.pos.x * TILE, MAP_TOP + r.pos.y * TILE, 2, .Sage if r.visited else .Rose, 2)
	}
	draw_char(c, g.cat.x * TILE, MAP_TOP + g.cat.y * TILE, 'C', .Cat, 2)

	buf: [64]u8
	header := fmt.bprintf(buf[:], "Day %d of %d  Energy %d  Purr %d", g.day, DAYS_PER_RUN, g.energy, g.purr)
	draw_text(c, 2, 0, header, .Cream)
	if g.offering {
		draw_offer_menu(g)
	}
	draw_text_centered(c, VIEW_HEIGHT - FONT_HEIGHT, g.message if g.message != "" else "Arrows move. Walk into someone to visit. B naps.", .Gold)
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
	total := fmt.bprintf(buf[:], "Day %d of %d  Purr %d", g.day, DAYS_PER_RUN, g.purr)
	draw_text_centered(c, 142, total, .Gold)
	draw_text_centered(c, VIEW_HEIGHT - FONT_HEIGHT, "Press A", .Gold)
}
