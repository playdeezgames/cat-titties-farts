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
	"Minutes: Motion to table the TITTIES. Seconded.",
	"Minutes: Members compared sizes. Of the biscuits.",
	"Minutes: Dolores found a lump. It was the cake.",
	"Minutes: Annual report. Nurse is still laughing.",
}
// What a member says when the cat visits during a meeting (format args: name, purr). Each fits the message line.
MEETING_QUIPS := [6]string {
	"%s: the TITTIES are out. +%d purr.",
	"%s lifts the tea cosy. +%d purr.",
	"%s: nice pair of needles. +%d purr.",
	"%s wants a firm grip. +%d purr.",
	"%s: hold my tatting. +%d purr.",
	"%s: bigger than last year. +%d purr.",
}
// What the room says when the cat farts and nobody minds. Short, because it follows the visit result on one line.
FART_QUIPS := [4]string {
	"The cat farts. Nobody minds.",
	"The cat farts. Blame the chair.",
	"The cat farts. Hearty applause.",
	"The cat farts. Tea cosy helps.",
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

// The how-to-play booklet. Each page is wrapped to the screen by wrap_text, so the strings are plain sentences.
HELP_PAGES :: 5
HELP_TITLES := [HELP_PAGES]string{"THE JOB", "VISITING", "WHEN", "THE TITTIES", "KEYS"}
HELP_TEXT := [HELP_PAGES]string {
	"You are the cat. It is the afternoon at the care home and everyone would like a visit. Nobody wants the same kind of visit, and you cannot see them all.\nEvery step you take costs 1 energy. At 0 the day is over. Five days make a run. Earn as much purr as you can.\nPress Up in this booklet to bring back the guide.",
	"Walk into a resident to visit them. A menu opens. Look at what they are doing: patting their knees means a lap, eyes closed means quiet, holding a book means a story, glancing at the biscuit tin means a treat.\nPick the match: they cheer up and you earn 10 purr. Pick wrong: they sulk, and you lose extra energy.",
	"Residents only receive visitors at certain times, shown as how much energy you have left. Walk into someone who is not receiving and the game tells you when they will be.\nEveryone gets one visit a day. Anyone you skip is a little quieter tomorrow, and moods carry over from day to day.",
	"The teal residents in the hall are the Tuesday Indoor Tatting and Tea Interest Exchange Society: the TITTIES. They meet from the start of each day until you have used 30 energy. A matched visit to a member pays double purr.\nMembership is open to anyone with a good pair of needles. The cat has been asked to give the bigger ones a firm, steady look.\nThe night nurse has stopped trying to say it with a straight face.",
	"Move: arrow keys, WASD or the number pad.\nA, Enter or Space: choose, and open this booklet while walking.\nB or Escape: go back. While walking, B offers to nap, which ends the day.\nOn a phone, use the buttons under the picture.\nUp: close the booklet and switch the guide back on for the rest of the day.\nYour run is saved at the start of every day.",
}
