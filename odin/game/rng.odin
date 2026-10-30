package game

// SplitMix64. Self-contained so native tests and the wasm build draw identical sequences.
Rng :: struct {
	state: u64,
}

rng_seed :: proc(r: ^Rng, seed: u64) {
	r.state = seed
}

rng_next :: proc(r: ^Rng) -> u64 {
	r.state += 0x9E3779B97F4A7C15
	z := r.state
	z = (z ~ (z >> 30)) * 0xBF58476D1CE4E5B9
	z = (z ~ (z >> 27)) * 0x94D049BB133111EB
	return z ~ (z >> 31)
}

// Uniform in [0, n). Returns 0 when n <= 0, but still consumes a draw.
rng_below :: proc(r: ^Rng, n: int) -> int {
	v := rng_next(r)
	if n <= 0 {
		return 0
	}
	return int(v % u64(n))
}

// Inclusive on both ends.
rng_range :: proc(r: ^Rng, minimum, maximum: int) -> int {
	return rng_below(r, maximum - minimum + 1) + minimum
}
