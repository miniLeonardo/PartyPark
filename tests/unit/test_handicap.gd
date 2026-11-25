extends TestCase
## Tests für das Handicap je Spieler (P3, D135).


func test_normal_changes_nothing() -> void:
	var n: int = Handicap.Level.NORMAL
	assert_eq(Handicap.speed(n), 1.0, "Tempo")
	assert_eq(Handicap.push_taken(n), 1.0, "Schubs-Wucht")
	assert_eq(Handicap.timing_window(n), 1.0, "Zeitfenster")
	assert_eq(Handicap.hit_radius(n), 1.0, "Trefferradius")


func test_relaxed_is_easier_than_pro() -> void:
	var pro: int = Handicap.Level.PRO
	var relaxed: int = Handicap.Level.RELAXED
	assert_true(Handicap.speed(relaxed) > Handicap.speed(pro), "Entspannt schneller")
	assert_true(Handicap.push_taken(relaxed) < Handicap.push_taken(pro), "Entspannt standfester")
	assert_true(Handicap.timing_window(relaxed) > Handicap.timing_window(pro), "Entspannt großzügiger")


func test_step_clamps() -> void:
	assert_eq(Handicap.step(Handicap.Level.PRO, -1), Handicap.Level.PRO, "unten begrenzt")
	assert_eq(Handicap.step(Handicap.Level.RELAXED, 1), Handicap.Level.RELAXED, "oben begrenzt")
	assert_eq(Handicap.step(Handicap.Level.NORMAL, 1), Handicap.Level.RELAXED, "weiterblättern")


func test_cpu_stays_normal() -> void:
	var slot := PlayerSlot.new(0, Color.WHITE, "Test")
	slot.handicap = Handicap.Level.RELAXED
	slot.is_cpu = true
	assert_eq(slot.effective_handicap(), Handicap.Level.NORMAL, "Computer immer Normal")
	slot.is_cpu = false
	assert_eq(slot.effective_handicap(), Handicap.Level.RELAXED, "Mensch behält Stufe")
