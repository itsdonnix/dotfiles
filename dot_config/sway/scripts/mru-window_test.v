module main

fn test_update_history_keeps_two_most_recent_unique_windows() {
	assert update_history([]i64{}, 10) == [i64(10)]
	assert update_history([i64(10)], 20) == [i64(20), 10]
	assert update_history([i64(20), 10], 10) == [i64(10), 20]
	assert update_history([i64(10), 20], 20) == [i64(20), 10]
}

fn test_update_history_ignores_duplicate_and_invalid_entries() {
	assert update_history([i64(20), 20, 0, -1, 10], 30) == [i64(30), 20]
	assert update_history([i64(20), 10], 20) == [i64(20), 10]
}

fn test_choose_toggle_target_switches_between_two_recent_windows() {
	valid := {
		i64(10): true
		i64(20): true
	}

	target_from_20, cleaned_from_20 := choose_toggle_target([i64(20), 10], valid, 20)
	assert target_from_20 == 10
	assert cleaned_from_20 == [i64(20), 10]

	// After focus event for 10, history becomes [10, 20].
	history_after_focus := update_history(cleaned_from_20, 10)
	assert history_after_focus == [i64(10), 20]

	target_from_10, cleaned_from_10 := choose_toggle_target(history_after_focus, valid, 10)
	assert target_from_10 == 20
	assert cleaned_from_10 == [i64(10), 20]
}

fn test_choose_toggle_target_removes_stale_windows() {
	valid := {
		i64(10): true
		i64(20): true
	}
	target, cleaned := choose_toggle_target([i64(99), 20, 10], valid, 20)
	assert target == 10
	assert cleaned == [i64(20), 10]
}

fn test_choose_toggle_target_returns_zero_when_no_other_window_exists() {
	valid := {
		i64(10): true
	}
	target, cleaned := choose_toggle_target([i64(10), 99], valid, 10)
	assert target == 0
	assert cleaned == [i64(10)]
}
