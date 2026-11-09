///|
test "occurrence counts respect shared suffixes and restrictions retain item IDs" {
  assert_eq(Family::powerset(5).occurrences(), [16UL, 16UL, 16UL, 16UL, 16UL])
  assert_eq(Family::choose(5, 2).occurrences(), [4UL, 4UL, 4UL, 4UL, 4UL])
  let f = Family::powerset(5).restrict([0, 3], [1])
  assert_eq(f.count(), 4UL)
  assert_eq(f.occurrences(), [4UL, 0UL, 2UL, 4UL, 2UL])
  assert_true(f.contains([0, 2, 3, 4]))
  assert_eq(Family::empty(2).occurrences(), [0UL, 0UL])
}
