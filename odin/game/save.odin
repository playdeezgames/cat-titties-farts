package game

import "core:fmt"
import "core:strconv"
import "core:strings"

// Where the run is kept between visits. The platform supplies it; either proc may be nil (tests, no storage).
Storage :: struct {
	get: proc(key: string) -> (string, bool),
	set: proc(key: string, value: string),
}

SAVE_KEY :: "nhc:run"
SAVE_TAG :: "nhc1"

// A run is saved at the start of each day, so continuing restarts that day: same wants, full energy.
SaveData :: struct {
	day:           int,
	purr:          int,
	member_visits: int,
	rng_state:     u64,
	moods:         [RESIDENT_COUNT]int,
	wants:         [RESIDENT_COUNT]int,
}

format_save :: proc(g: ^Game, buf: []u8) -> string {
	b := strings.builder_from_bytes(buf)
	fmt.sbprintf(&b, "%s %d %d %d %d", SAVE_TAG, g.day, g.purr, g.member_visits, g.rng.state)
	for r in g.residents {
		fmt.sbprintf(&b, " %d", r.mood)
	}
	for r in g.residents {
		fmt.sbprintf(&b, " %d", int(r.want))
	}
	return strings.to_string(b)
}

// Refuses anything malformed or out of range, so a damaged save can never put the game in a state it cannot reach.
parse_save :: proc(text: string) -> (data: SaveData, ok: bool) {
	fields := strings.fields(text, context.temp_allocator)
	if len(fields) != 5 + 2 * RESIDENT_COUNT || fields[0] != SAVE_TAG {
		return
	}
	number :: proc(s: string, low, high: int) -> (int, bool) {
		n, parsed := strconv.parse_int(s)
		return n, parsed && n >= low && n <= high
	}
	data.day = number(fields[1], 1, DAYS_PER_RUN) or_return
	data.purr = number(fields[2], 0, 1_000_000) or_return
	data.member_visits = number(fields[3], 0, 1_000_000) or_return
	data.rng_state = strconv.parse_u64(fields[4]) or_return
	for i in 0 ..< RESIDENT_COUNT {
		data.moods[i] = number(fields[5 + i], 0, MOOD_MAX) or_return
		data.wants[i] = number(fields[5 + RESIDENT_COUNT + i], 0, len(Want) - 1) or_return
	}
	return data, true
}

save_run :: proc(g: ^Game) {
	if g.storage.set == nil {
		return
	}
	buf: [256]u8
	g.storage.set(SAVE_KEY, format_save(g, buf[:]))
	g.saved = true
}

clear_save :: proc(g: ^Game) {
	if g.storage.set != nil {
		g.storage.set(SAVE_KEY, "")
	}
	g.saved = false
}

// Reads the stored run into g.save (when there is a good one) and sets g.saved.
find_save :: proc(g: ^Game) {
	g.saved = false
	if g.storage.get == nil {
		return
	}
	if text, found := g.storage.get(SAVE_KEY); found {
		g.save, g.saved = parse_save(text)
	}
}
