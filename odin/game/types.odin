package game

Command :: enum {
	Up,
	Right,
	Down,
	Left,
	A,
	B,
}

Screen :: enum {
	Title,
	Rounds,
	Ledger,
}

Hue :: enum u8 {
	Night,
	Wall,
	Floor,
	Cream,
	Rose,
	Sage,
	Gold,
	Gray,
	Cat,
}

Want :: enum {
	Lap,
	Quiet,
	Story,
	Treat,
}

Resident :: struct {
	pos:     [2]int,
	name:    string,
	want:    Want,
	mood:    int,
	// Member of the Tuesday Indoor Tatting & Tea Interest Exchange Society.
	member:  bool,
	visited: bool,
}

Game :: struct {
	screen:      Screen,
	rng:         Rng,
	day:         int,
	cat:         [2]int,
	energy:      int,
	residents:   [RESIDENT_COUNT]Resident,
	purr:        int,
	// The offer menu is open for residents[target], with the cursor on one of the four offers.
	offering:    bool,
	target:      int,
	cursor:      Want,
	message:     string,
	message_buf: [96]u8,
	canvas:      Canvas,
	// RGBA bytes of the last frame, read by the page.
	pixels:      [VIEW_WIDTH * VIEW_HEIGHT]u32,
}
