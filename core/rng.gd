class_name RNG
extends RefCounted
## PRNG determinista (xorshift32) para seeds reproducibles.
## No usa el RandomNumberGenerator global: una misma seed da la misma secuencia.

var state: int = 0

func _init(seed_value: int = 0) -> void:
	seed(seed_value)

func seed(s: int) -> void:
	state = (s ^ 0x5BD1E995) & 0xFFFFFFFF
	if state == 0:
		state = 1

func next_u32() -> int:
	var x := state
	x ^= (x << 13) & 0xFFFFFFFF
	x &= 0xFFFFFFFF
	x ^= x >> 17
	x ^= (x << 5) & 0xFFFFFFFF
	state = x & 0xFFFFFFFF
	return state

func next_float() -> float:
	return float(next_u32() & 0xFFFFFF) / float(0x1000000)

## Entero en [a, b] inclusive.
func rangei(a: int, b: int) -> int:
	if b <= a:
		return a
	return a + int(next_u32() % (b - a + 1))

## true con probabilidad p (0..1).
func chance(p: float) -> bool:
	return next_float() < p

## Índice ponderado a partir de un Array de pesos (float).
func pick_index(weights: Array) -> int:
	var total := 0.0
	for w in weights:
		total += float(w)
	if total <= 0.0:
		return rangei(0, weights.size() - 1)
	var r := next_float() * total
	var acc := 0.0
	for i in weights.size():
		acc += float(weights[i])
		if r < acc:
			return i
	return weights.size() - 1

## Devuelve un elemento aleatorio del array (uniforme).
func pick(items: Array) -> Variant:
	if items.is_empty():
		return null
	return items[rangei(0, items.size() - 1)]

## Hash FNV-1a determinista de un string -> int 32 bits.
static func hash_string(s: String) -> int:
	var h := 2166136261
	for i in s.length():
		h = ((h ^ s.unicode_at(i)) * 16777619) & 0xFFFFFFFF
	return h
