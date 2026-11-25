extends TestCase
## Tests für die Kronenjagd im Park (P2, D134).


func test_leader_is_longest_carrier() -> void:
	assert_eq(HubCrownHunt.leader_of({0: 3.0, 1: 12.5, 2: 4.0}), 1, "längste Tragezeit führt")


func test_leader_tie_prefers_lower_slot() -> void:
	assert_eq(HubCrownHunt.leader_of({2: 5.0, 0: 5.0}), 0, "Gleichstand: niedrigerer Platz")


func test_no_leader_without_carry_time() -> void:
	assert_eq(HubCrownHunt.leader_of({0: 0.0, 1: 0.0}), -1, "niemand hatte die Krone")
