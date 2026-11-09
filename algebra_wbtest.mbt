///|
test "intersection and ordered difference match membership" {
  let a = Family::from_sets(3, [[], [0], [1, 2]])
  let b = Family::from_sets(3, [[], [2], [1, 2]])
  let common = a.intersection(b)
  let minus = a.difference(b)
  for subset in [[], [0], [1], [2], [0, 1], [0, 2], [1, 2], [0, 1, 2]] {
    assert_eq(common.contains(subset), a.contains(subset) && b.contains(subset))
    assert_eq(minus.contains(subset), a.contains(subset) && !b.contains(subset))
  }
  assert_true(a.difference(a).is_empty())
}
