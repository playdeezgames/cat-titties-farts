package game

// One floor of the home. '#' wall, '.' floor, 'R' a resident, 'M' a TITTIES member (the hall in the middle of the
// top row is their meeting room), 'C' where the cat starts. Furniture blocks: b bed, c chair, t table, s sofa,
// k shelf, p plant.
MAP_WIDTH :: 26
MAP_HEIGHT :: 13
TILE :: TILE_SIZE
MAP_TOP :: 8

MAP_ROWS := [MAP_HEIGHT]string {
	"##########################",
	"#R.b.#k...R#M..t..M.#R.p.#",
	"#....#.....#.c.M.c..#....#",
	"#b...#k....#........#...p#",
	"##.#####.######..#####.###",
	"#...p...............p....#",
	"#............C...........#",
	"#....c.............c.....#",
	"###.########.#########.###",
	"#b...b.#sss.......#c.t.c.#",
	"#......#.....R....#......#",
	"#.p..p.#k........k#..b..b#",
	"##########################",
}

RESIDENT_COUNT :: 7
ENERGY_MAX :: 60
DAYS_PER_RUN :: 5

MEMBER_COUNT :: 3
OTHER_COUNT :: RESIDENT_COUNT - MEMBER_COUNT
// Handed out in the order the residents appear on the map (rows top to bottom, then left to right).
MEMBER_NAMES := [MEMBER_COUNT]string{"Dolores", "Mrs. Okafor", "Bernice"}
OTHER_NAMES := [OTHER_COUNT]string{"Walter", "Mr. Lindqvist", "Mrs. Abernathy", "Harold"}

MOOD_START :: 3
MOOD_MAX :: 5
// Non-members only receive visitors while the energy spent so far is inside their window. Members meet in the hall
// from the start of the day until MEETING_END.
OTHER_WINDOWS := [OTHER_COUNT][2]int{{10, 50}, {20, 60}, {30, 60}, {15, 45}}
// Members meet until this much energy is spent; a matched visit then earns double purr.
MEETING_END :: 30

// The society's secretary takes minutes every day; each fits on one line of the ledger.
MINUTES := [DAYS_PER_RUN]string {
	"Minutes: Item 1, the name. Item 1 carried again.",
	"Minutes: Tatting motion passed. Nurse left room.",
	"Minutes: Biscuits were discussed at length.",
	"Minutes: New signage. Nurse asked to be excused.",
	"Minutes: Annual report. Nurse is still laughing.",
}
PURR_MATCH :: 10
MISMATCH_EXTRA_COST :: 3
// One lap visit in this many ends in a fart.
FART_ODDS :: 4

// What each offer costs in energy.
OFFER_COST := [Want]int {
	.Lap   = 6,
	.Quiet = 2,
	.Story = 5,
	.Treat = 4,
}

OFFER_TEXT := [Want]string {
	.Lap   = "Sit in their lap",
	.Quiet = "Sit nearby, quietly",
	.Story = "Listen to their story",
	.Treat = "Accept a treat",
}

// What the resident is doing that gives the want away.
WANT_HINT := [Want]string {
	.Lap   = "patting their knees",
	.Quiet = "eyes closed",
	.Story = "holding a book",
	.Treat = "glancing at the biscuit tin",
}

WANT_TEXT := [Want]string {
	.Lap   = "a warm lap",
	.Quiet = "quiet",
	.Story = "a story",
	.Treat = "a treat",
}

is_wall :: proc(x, y: int) -> bool {
	if x < 0 || y < 0 || x >= MAP_WIDTH || y >= MAP_HEIGHT {
		return true
	}
	switch MAP_ROWS[y][x] {
	case '#', 'b', 'c', 't', 's', 'k', 'p':
		return true
	}
	return false
}
