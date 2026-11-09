///|
test "relations and XOR are based on sets rather than graph IDs" {
  let a = Family::from_sets(3, [[2], [], [0, 1]])
  let b = Family::from_sets(3, [[0, 1], [], [2], [2]])
  assert_true(a.equivalent(b))
  let c = Family::from_sets(3, [[2], [1]])
  let delta = a.symmetric_difference(c)
  for subset in [[], [0], [1], [2], [0, 1], [1, 2]] {
    assert_eq(delta.contains(subset), a.contains(subset) != c.contains(subset))
  }
  assert_true(a.intersection(c).is_subfamily(a))
  assert_true(a.difference(c).is_disjoint(c))
}
