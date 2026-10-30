package game

// The software framebuffer: 320x180 hue indices and DINOBYTE bitmap text. Every write is bounds-checked and clipped.

VIEW_WIDTH :: 320
VIEW_HEIGHT :: 180

Canvas :: struct {
	pixels: [VIEW_WIDTH * VIEW_HEIGHT]Hue,
}

// Each entry is 0xAABBGGRR, so the bytes in memory are R, G, B, A.
PALETTE := [Hue]u32 {
	.Night = 0xFF1C1418,
	.Wall  = 0xFF424862,
	.Floor = 0xFF8CAAC4,
	.Cream = 0xFFD0E8F4,
	.Rose  = 0xFF8C82D6,
	.Sage  = 0xFF82AA84,
	.Gold  = 0xFF5ABEEC,
	.Gray  = 0xFF8E868C,
	.Cat   = 0xFF3C8CE8,
}

canvas_set :: proc(c: ^Canvas, x, y: int, hue: Hue) {
	if x < 0 || y < 0 || x >= VIEW_WIDTH || y >= VIEW_HEIGHT {
		return
	}
	c.pixels[x + y * VIEW_WIDTH] = hue
}

canvas_fill :: proc(c: ^Canvas, x, y, w, h: int, hue: Hue) {
	for dy in 0 ..< h {
		for dx in 0 ..< w {
			canvas_set(c, x + dx, y + dy, hue)
		}
	}
}

canvas_clear :: proc(c: ^Canvas, hue: Hue) {
	canvas_fill(c, 0, 0, VIEW_WIDTH, VIEW_HEIGHT, hue)
}

text_width :: proc(text: string, scale := 1) -> int {
	return len(text) * FONT_WIDTH * scale
}

// Code page 437 glyph code; ASCII text maps straight onto it.
draw_char :: proc(c: ^Canvas, x, y: int, code: u8, hue: Hue, scale := 1) {
	glyph := &FONT_GLYPHS[code]
	for row in 0 ..< FONT_HEIGHT {
		bits := glyph[row]
		for col in 0 ..< FONT_WIDTH {
			if bits & (1 << uint(col)) != 0 {
				canvas_fill(c, x + col * scale, y + row * scale, scale, scale, hue)
			}
		}
	}
}

draw_text :: proc(c: ^Canvas, x, y: int, text: string, hue: Hue, scale := 1) {
	for i in 0 ..< len(text) {
		draw_char(c, x + i * FONT_WIDTH * scale, y, text[i], hue, scale)
	}
}

draw_text_centered :: proc(c: ^Canvas, y: int, text: string, hue: Hue, scale := 1) {
	draw_text(c, VIEW_WIDTH / 2 - text_width(text, scale) / 2, y, text, hue, scale)
}

canvas_to_rgba :: proc(c: ^Canvas, out: ^[VIEW_WIDTH * VIEW_HEIGHT]u32) {
	for p, i in c.pixels {
		out[i] = PALETTE[p]
	}
}
