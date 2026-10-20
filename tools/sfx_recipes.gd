extends RefCounted
## Rezepte für `tools/sfx_gen.gd` (D59: weich-comichaft, runde Wellen). Name = Dateiname in
## `assets/audio/sfx/`. Werte frei änderbar, danach Generator und Import neu laufen lassen.
## Die Rezepte sind Platzhalter-Klangdesign; Leonardo stimmt sie nach dem Hörtest ab.

const C5: float = 523.25
const D5: float = 587.33
const E5: float = 659.25
const G5: float = 783.99
const A5: float = 880.0
const C6: float = 1046.5
const E6: float = 1318.5
const G4: float = 392.0
const E4: float = 329.63
const C4: float = 261.63


static func all() -> Dictionary:
	var r: Dictionary = {}
	# --- Menü (D62) ---
	r["ui_move"] = {"wave": "sine", "freq": 900.0, "freq_end": 1000.0, "attack": 0.002, "sustain": 0.01, "decay": 0.05, "volume": 0.5}
	r["ui_confirm"] = {"layers": [
		{"wave": "sine", "freq": 520.0, "freq_end": 1040.0, "attack": 0.003, "sustain": 0.03, "decay": 0.09},
		{"wave": "triangle", "freq": 1040.0, "attack": 0.003, "sustain": 0.02, "decay": 0.12, "delay": 0.05, "volume": 0.5}], "volume": 0.7}
	r["ui_back"] = {"wave": "sine", "freq": 700.0, "freq_end": 330.0, "attack": 0.003, "sustain": 0.03, "decay": 0.1, "volume": 0.6}
	r["join"] = {"wave": "triangle", "freq": 300.0, "freq_end": 900.0, "vibrato": [1.5, 18.0], "attack": 0.005, "sustain": 0.12, "decay": 0.15, "lowpass": 3000.0, "volume": 0.8}
	r["leave"] = {"wave": "triangle", "freq": 700.0, "freq_end": 220.0, "attack": 0.005, "sustain": 0.08, "decay": 0.15, "lowpass": 2500.0, "volume": 0.7}
	r["pause"] = {"layers": [
		{"wave": "sine", "freq": E5, "attack": 0.003, "sustain": 0.04, "decay": 0.1},
		{"wave": "sine", "freq": C5, "attack": 0.003, "sustain": 0.04, "decay": 0.15, "delay": 0.07}], "volume": 0.6}
	r["countdown_tick"] = {"wave": "sine", "freq": 660.0, "attack": 0.003, "sustain": 0.08, "decay": 0.12, "punch": 0.3, "volume": 0.7}
	r["countdown_go"] = {"layers": [
		{"wave": "sine", "freq": C6, "attack": 0.003, "sustain": 0.18, "decay": 0.3, "punch": 0.4},
		{"wave": "triangle", "freq": G5, "attack": 0.003, "sustain": 0.18, "decay": 0.3, "volume": 0.6},
		{"wave": "sine", "freq": E5, "attack": 0.003, "sustain": 0.18, "decay": 0.3, "volume": 0.5}], "volume": 0.8}
	r["win"] = {"layers": [
		{"wave": "triangle", "freq": C5, "attack": 0.005, "sustain": 0.08, "decay": 0.05},
		{"wave": "triangle", "freq": E5, "attack": 0.005, "sustain": 0.08, "decay": 0.05, "delay": 0.12},
		{"wave": "triangle", "freq": G5, "attack": 0.005, "sustain": 0.08, "decay": 0.05, "delay": 0.24},
		{"wave": "triangle", "freq": C6, "vibrato": [0.3, 6.0], "attack": 0.005, "sustain": 0.35, "decay": 0.35, "delay": 0.36},
		{"wave": "sine", "freq": E6, "attack": 0.005, "sustain": 0.35, "decay": 0.35, "delay": 0.36, "volume": 0.4}], "volume": 0.8}
	r["lose"] = {"layers": [
		{"wave": "triangle", "freq": G4, "vibrato": [0.4, 5.0], "attack": 0.01, "sustain": 0.18, "decay": 0.05, "lowpass": 1800.0},
		{"wave": "triangle", "freq": 370.0, "vibrato": [0.4, 5.0], "attack": 0.01, "sustain": 0.18, "decay": 0.05, "delay": 0.25, "lowpass": 1800.0},
		{"wave": "triangle", "freq": 349.2, "freq_end": 300.0, "vibrato": [0.8, 5.0], "attack": 0.01, "sustain": 0.4, "decay": 0.3, "delay": 0.5, "lowpass": 1800.0}], "volume": 0.7}
	# --- Figur ---
	r["jump"] = {"wave": "sine", "freq": 260.0, "freq_end": 620.0, "attack": 0.003, "sustain": 0.05, "decay": 0.08, "volume": 0.55}
	r["land"] = {"wave": "sine", "freq": 160.0, "freq_end": 70.0, "noise": 0.15, "attack": 0.002, "sustain": 0.02, "decay": 0.08, "lowpass": 900.0, "volume": 0.6}
	r["push"] = {"wave": "noise", "freq": 1800.0, "freq_end": 600.0, "attack": 0.01, "sustain": 0.04, "decay": 0.08, "lowpass": 2500.0, "volume": 0.45, "seed": 3}
	r["hit"] = {"layers": [
		{"wave": "sine", "freq": 420.0, "freq_end": 160.0, "attack": 0.002, "sustain": 0.03, "decay": 0.12, "punch": 0.5},
		{"wave": "noise", "freq": 1200.0, "attack": 0.001, "sustain": 0.01, "decay": 0.04, "lowpass": 2000.0, "volume": 0.4}], "volume": 0.75, "seed": 4}
	r["spawn"] = {"wave": "sine", "freq": 500.0, "freq_end": 1300.0, "attack": 0.003, "sustain": 0.03, "decay": 0.08, "volume": 0.45}
	r["eliminated"] = {"wave": "triangle", "freq": 600.0, "freq_end": 120.0, "vibrato": [1.0, 9.0], "attack": 0.01, "sustain": 0.25, "decay": 0.25, "lowpass": 2000.0, "volume": 0.75}
	r["sparkle"] = {"layers": [
		{"wave": "sine", "freq": 1568.0, "attack": 0.002, "sustain": 0.02, "decay": 0.12, "volume": 0.6},
		{"wave": "sine", "freq": 2093.0, "attack": 0.002, "sustain": 0.02, "decay": 0.15, "delay": 0.05, "volume": 0.5},
		{"wave": "sine", "freq": 2637.0, "attack": 0.002, "sustain": 0.02, "decay": 0.18, "delay": 0.1, "volume": 0.4}], "volume": 0.5}
	r["splash"] = {"layers": [
		{"wave": "noise", "freq": 3000.0, "freq_end": 800.0, "attack": 0.005, "sustain": 0.08, "decay": 0.35, "lowpass": 3500.0},
		{"wave": "sine", "freq": 300.0, "freq_end": 900.0, "attack": 0.003, "sustain": 0.02, "decay": 0.06, "volume": 0.5},
		{"wave": "sine", "freq": 500.0, "freq_end": 1200.0, "attack": 0.003, "sustain": 0.02, "decay": 0.06, "delay": 0.08, "volume": 0.35}], "volume": 0.8, "seed": 5}
	# --- Autoscooter ---
	r["bump"] = {"layers": [
		{"wave": "sine", "freq": 260.0, "freq_end": 110.0, "vibrato": [2.0, 30.0], "attack": 0.002, "sustain": 0.05, "decay": 0.15, "punch": 0.6},
		{"wave": "triangle", "freq": 520.0, "freq_end": 260.0, "attack": 0.002, "sustain": 0.02, "decay": 0.08, "volume": 0.4}], "volume": 0.85}
	r["turbo"] = {"layers": [
		{"wave": "saw", "freq": 120.0, "freq_end": 360.0, "attack": 0.01, "sustain": 0.12, "decay": 0.12, "lowpass": 900.0},
		{"wave": "noise", "freq": 2000.0, "attack": 0.02, "sustain": 0.1, "decay": 0.12, "lowpass": 1800.0, "volume": 0.4}], "volume": 0.7, "seed": 6}
	# --- Riese gegen Zwerge ---
	r["stomp"] = {"layers": [
		{"wave": "sine", "freq": 110.0, "freq_end": 40.0, "attack": 0.003, "sustain": 0.08, "decay": 0.35, "punch": 0.8},
		{"wave": "noise", "freq": 600.0, "freq_end": 150.0, "attack": 0.003, "sustain": 0.05, "decay": 0.3, "lowpass": 700.0, "volume": 0.6}], "volume": 0.95, "seed": 7}
	r["rope_wrap"] = {"wave": "triangle", "freq": 400.0, "freq_end": 800.0, "attack": 0.01, "sustain": 0.05, "decay": 0.05, "lowpass": 2500.0, "volume": 0.4}
	r["rope_done"] = {"layers": [
		{"wave": "triangle", "freq": G5, "attack": 0.003, "sustain": 0.04, "decay": 0.12},
		{"wave": "triangle", "freq": C6, "attack": 0.003, "sustain": 0.06, "decay": 0.2, "delay": 0.07}], "volume": 0.7}
	r["rope_shake"] = {"wave": "noise", "freq": 900.0, "freq_end": 3000.0, "attack": 0.005, "sustain": 0.06, "decay": 0.12, "lowpass": 3000.0, "volume": 0.6, "seed": 8}
	r["giant_fall"] = {"layers": [
		{"wave": "sine", "freq": 90.0, "freq_end": 30.0, "attack": 0.005, "sustain": 0.25, "decay": 0.6, "punch": 1.0},
		{"wave": "noise", "freq": 400.0, "freq_end": 80.0, "attack": 0.005, "sustain": 0.2, "decay": 0.6, "lowpass": 600.0, "volume": 0.7},
		{"wave": "triangle", "freq": 500.0, "freq_end": 150.0, "vibrato": [1.0, 8.0], "attack": 0.01, "sustain": 0.3, "decay": 0.2, "volume": 0.3}], "volume": 0.95, "seed": 9}
	# --- Tauziehen ---
	r["beat"] = {"wave": "sine", "freq": 220.0, "freq_end": 180.0, "attack": 0.002, "sustain": 0.01, "decay": 0.06, "volume": 0.4}
	r["pull"] = {"layers": [
		{"wave": "sine", "freq": 180.0, "freq_end": 120.0, "attack": 0.003, "sustain": 0.03, "decay": 0.08},
		{"wave": "noise", "freq": 800.0, "attack": 0.003, "sustain": 0.02, "decay": 0.05, "lowpass": 1200.0, "volume": 0.35}], "volume": 0.6, "seed": 10}
	r["sync"] = {"layers": [
		{"wave": "sine", "freq": E6, "attack": 0.002, "sustain": 0.02, "decay": 0.12},
		{"wave": "sine", "freq": 1975.5, "attack": 0.002, "sustain": 0.02, "decay": 0.15, "delay": 0.04, "volume": 0.6}], "volume": 0.5}
	r["slip"] = {"wave": "sine", "freq": 900.0, "freq_end": 250.0, "vibrato": [0.5, 12.0], "attack": 0.01, "sustain": 0.12, "decay": 0.1, "volume": 0.55}
	r["power"] = {"layers": [
		{"wave": "noise", "freq": 500.0, "freq_end": 2500.0, "attack": 0.08, "sustain": 0.1, "decay": 0.05, "lowpass": 2500.0, "volume": 0.6},
		{"wave": "sine", "freq": 120.0, "freq_end": 45.0, "attack": 0.003, "sustain": 0.1, "decay": 0.35, "punch": 0.8, "delay": 0.2}], "volume": 0.9, "seed": 11}
	r["mud"] = {"wave": "noise", "freq": 300.0, "freq_end": 700.0, "attack": 0.005, "sustain": 0.04, "decay": 0.1, "lowpass": 1100.0, "volume": 0.55, "seed": 12}
	# --- Schafe hüten ---
	r["bark"] = {"layers": [
		{"wave": "square", "freq": 520.0, "freq_end": 260.0, "duty": 0.35, "attack": 0.004, "sustain": 0.05, "decay": 0.08, "lowpass": 1600.0},
		{"wave": "noise", "freq": 1500.0, "attack": 0.002, "sustain": 0.03, "decay": 0.05, "lowpass": 2200.0, "volume": 0.5}], "volume": 0.75, "seed": 13}
	r["bleat"] = {"wave": "saw", "freq": 430.0, "freq_end": 400.0, "vibrato": [1.2, 22.0], "attack": 0.02, "sustain": 0.25, "decay": 0.12, "lowpass": 1400.0, "volume": 0.5}
	r["sheep_in"] = {"layers": [
		{"wave": "sine", "freq": A5, "attack": 0.002, "sustain": 0.03, "decay": 0.12},
		{"wave": "sine", "freq": E6, "attack": 0.002, "sustain": 0.05, "decay": 0.2, "delay": 0.06, "volume": 0.7}], "volume": 0.6}
	r["wolf_howl"] = {"wave": "sine", "freq": 380.0, "freq_end": 520.0, "vibrato": [0.6, 6.0], "attack": 0.15, "sustain": 0.5, "decay": 0.5, "noise": 0.05, "lowpass": 1600.0, "volume": 0.6, "seed": 14}
	r["wolf_yelp"] = {"wave": "triangle", "freq": 1100.0, "freq_end": 500.0, "attack": 0.003, "sustain": 0.05, "decay": 0.1, "lowpass": 2500.0, "volume": 0.6}
	# --- Wackelwaben ---
	r["tile_crack"] = {"layers": [
		{"wave": "noise", "freq": 2500.0, "attack": 0.001, "sustain": 0.02, "decay": 0.06, "lowpass": 4000.0},
		{"wave": "triangle", "freq": 320.0, "freq_end": 260.0, "vibrato": [3.0, 40.0], "attack": 0.002, "sustain": 0.12, "decay": 0.08, "volume": 0.5}], "volume": 0.55, "seed": 15}
	r["tile_fall"] = {"wave": "sine", "freq": 500.0, "freq_end": 120.0, "attack": 0.005, "sustain": 0.1, "decay": 0.2, "noise": 0.1, "lowpass": 1500.0, "volume": 0.45, "seed": 16}
	# --- Heiße Kartoffel ---
	r["tick"] = {"wave": "triangle", "freq": 1400.0, "freq_end": 1100.0, "attack": 0.001, "sustain": 0.01, "decay": 0.04, "volume": 0.45}
	r["pass"] = {"wave": "sine", "freq": 350.0, "freq_end": 1100.0, "attack": 0.003, "sustain": 0.03, "decay": 0.08, "volume": 0.6}
	r["explosion"] = {"layers": [
		{"wave": "noise", "freq": 900.0, "freq_end": 90.0, "attack": 0.002, "sustain": 0.15, "decay": 0.7, "lowpass": 2200.0, "punch": 1.0},
		{"wave": "sine", "freq": 120.0, "freq_end": 35.0, "attack": 0.002, "sustain": 0.1, "decay": 0.5, "punch": 0.8, "volume": 0.8},
		{"wave": "triangle", "freq": 900.0, "freq_end": 300.0, "vibrato": [1.0, 10.0], "attack": 0.01, "sustain": 0.05, "decay": 0.2, "delay": 0.05, "volume": 0.25}], "volume": 1.0, "seed": 17}
	# --- Zerfetzung ---
	r["blaster"] = {"layers": [
		{"wave": "square", "freq": 900.0, "freq_end": 250.0, "duty": 0.3, "attack": 0.002, "sustain": 0.03, "decay": 0.07, "lowpass": 2600.0},
		{"wave": "noise", "freq": 3000.0, "attack": 0.001, "sustain": 0.01, "decay": 0.03, "lowpass": 3000.0, "volume": 0.3}], "volume": 0.5, "seed": 18}
	r["impact"] = {"wave": "noise", "freq": 1500.0, "freq_end": 400.0, "attack": 0.001, "sustain": 0.01, "decay": 0.06, "lowpass": 2000.0, "volume": 0.4, "seed": 19}
	r["splat"] = {"layers": [
		{"wave": "noise", "freq": 700.0, "freq_end": 200.0, "attack": 0.002, "sustain": 0.03, "decay": 0.12, "lowpass": 1500.0},
		{"wave": "sine", "freq": 300.0, "freq_end": 120.0, "attack": 0.002, "sustain": 0.03, "decay": 0.1, "punch": 0.6, "volume": 0.7}], "volume": 0.75, "seed": 20}
	r["shred"] = {"layers": [
		{"wave": "noise", "freq": 1200.0, "freq_end": 120.0, "attack": 0.002, "sustain": 0.12, "decay": 0.5, "lowpass": 2500.0, "punch": 1.0},
		{"wave": "sine", "freq": 160.0, "freq_end": 40.0, "attack": 0.002, "sustain": 0.1, "decay": 0.4, "punch": 0.8, "volume": 0.8},
		{"wave": "triangle", "freq": 700.0, "freq_end": 1400.0, "attack": 0.005, "sustain": 0.05, "decay": 0.15, "delay": 0.08, "volume": 0.3},
		{"wave": "sine", "freq": 500.0, "freq_end": 900.0, "attack": 0.003, "sustain": 0.02, "decay": 0.06, "delay": 0.2, "volume": 0.3}], "volume": 0.95, "seed": 21}
	r["overheat"] = {"wave": "noise", "freq": 4000.0, "freq_end": 1500.0, "attack": 0.02, "sustain": 0.3, "decay": 0.3, "lowpass": 5000.0, "highpass": 800.0, "volume": 0.45, "seed": 22}
	# --- Ansager-Silben (WP 4.4): weiche Plapperlaute, Tonhöhe wird beim Abspielen variiert ---
	var vowels: Array = [[700.0, 1100.0], [400.0, 1900.0], [300.0, 2300.0], [500.0, 900.0], [350.0, 700.0], [650.0, 1500.0]]
	for i: int in vowels.size():
		var formant: Array = vowels[i]
		r["voice_%d" % i] = {"layers": [
			{"wave": "triangle", "freq": 220.0, "freq_end": 235.0 + 10.0 * i, "attack": 0.008, "sustain": 0.05, "decay": 0.04, "lowpass": float(formant[0]) * 2.2},
			{"wave": "sine", "freq": float(formant[0]), "attack": 0.008, "sustain": 0.04, "decay": 0.04, "volume": 0.35},
			{"wave": "sine", "freq": float(formant[1]), "attack": 0.008, "sustain": 0.03, "decay": 0.03, "volume": 0.15}], "volume": 0.7}
	return r
