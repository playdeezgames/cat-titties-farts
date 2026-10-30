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
	header := fmt.bprintf(buf[:], "Day %d of %d   Energy %d", g.day, DAYS_PER_RUN, g.energy)
	draw_text(c, 2, 0, header, .Cream)
	draw_text_centered(c, VIEW_HEIGHT - FONT_HEIGHT, g.message if g.message != "" else "Arrows move. B naps.", .Gold)
}

draw_ledger :: proc(g: ^Game) {
	c := &g.canvas
	draw_text_centered(c, 8, "The day is over", .Cream, 2)
	for r, i in g.residents {
		buf: [96]u8
		line: string
		if r.visited {
			line = fmt.bprintf(buf[:], "%s: visited", r.name)
		} else {
			line = fmt.bprintf(buf[:], "%s: not visited", r.name)
		}
		draw_text(c, 40, 40 + i * 14, line, .Sage if r.visited else .Gray)
	}
	draw_text_centered(c, VIEW_HEIGHT - FONT_HEIGHT, "Press A", .Gold)
}
