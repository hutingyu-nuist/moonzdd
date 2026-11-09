///|
test "join is a family of set unions, not a Cartesian tuple collection" {
  let a = Family::from_sets(3, [[0], [1]])
  let b = Family::from_sets(3, [[0], [2]])
  let c = a.join(b)
  assert_eq(c.count(), 4UL)
  for subset in [[0], [0, 2], [0, 1], [1, 2]] {
    assert_true(c.contains(subset))
  }
  assert_eq(a.disjoint_join(b).count(), 3UL)
  assert_false(a.disjoint_join(b).contains([0]))
  assert_true(a.join(Family::unit(3)).equivalent(a))
  assert_true(a.join(Family::empty(3)).is_empty())
}
