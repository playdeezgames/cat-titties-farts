package game

// One floor of the home. '#' wall, '.' floor, 'R' a resident (standing on floor), 'C' where the cat starts.
MAP_WIDTH :: 20
MAP_HEIGHT :: 10
TILE :: 16
MAP_TOP :: 8

MAP_ROWS := [MAP_HEIGHT]string {
	"####################",
	"#R...#...R#..R..#R.#",
	"#....#....#.....#..#",
	"##.####.#####.####.#",
	"#........C.........#",
	"#..................#",
	"##.###.#######.##.##",
	"#....#.....R.#...R.#",
	"#R...#.......#.....#",
	"####################",
}

RESIDENT_COUNT :: 7
ENERGY_MAX :: 60
DAYS_PER_RUN :: 5

RESIDENT_NAMES := [RESIDENT_COUNT]string{"Dolores", "Walter", "Mrs. Okafor", "Mr. Lindqvist", "Bernice", "Mrs. Abernathy", "Harold"}

MOOD_START :: 3
MOOD_MAX :: 5
// A resident only receives visitors while the energy spent so far is inside their window.
RESIDENT_WINDOWS := [RESIDENT_COUNT][2]int{{0, 30}, {10, 50}, {0, 30}, {20, 60}, {0, 30}, {30, 60}, {15, 45}}
RESIDENT_MEMBER := [RESIDENT_COUNT]bool{true, false, true, false, true, false, false}
// Members meet until this much energy is spent; a matched visit then earns double purr.
MEETING_END :: 30
PURR_MATCH :: 10
MISMATCH_EXTRA_COST :: 3

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
	return MAP_ROWS[y][x] == '#'
}
