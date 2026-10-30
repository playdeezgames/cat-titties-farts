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

// The page loads one wav per entry (its name in lower case, assets/sfx/<name>.wav); keep web/index.html in step.
Sfx :: enum u8 {
	None,
	Purr,
	Content,
	Wrong,
	Bell,
	Fart,
	Blip,
	Day_End,
	Bump,
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
	Shade,
	Brick,
	Wood,
	Leaf,
	Plum,
	Teal,
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
	// Energy spent when they start and stop receiving visitors.
	window:  [2]int,
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
	storage:     Storage,
	// A good saved run was found (g.save) or has just been written.
	saved:       bool,
	save:        SaveData,
	// Visits paid to TITTIES members this run (for the annual report).
	member_visits: int,
	// The offer menu is open for residents[target], with the cursor on one of the four offers.
	offering:    bool,
	target:      int,
	cursor:      Want,
	message:     string,
	message_buf: [96]u8,
	// Sounds raised since the page last collected them.
	sfx:         [16]Sfx,
	sfx_count:   int,
	canvas:      Canvas,
	// RGBA bytes of the last frame, read by the page.
	pixels:      [VIEW_WIDTH * VIEW_HEIGHT]u32,
}
