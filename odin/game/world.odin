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
