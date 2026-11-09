///|
test "minimal members retain incomparable sizes and empty set dominates" {
  let f = Family::from_sets(4, [[0], [0, 1], [1, 2, 3], [0, 2, 3]])
  let expected = Family::from_sets(4, [[0], [1, 2, 3]])
  assert_true(f.minimal().equivalent(expected))
  assert_true(f.union(Family::unit(4)).minimal().equivalent(Family::unit(4)))
  assert_true(
    f
    .without_supersets_of(Family::singleton(4, [0]))
    .equivalent(Family::singleton(4, [1, 2, 3])),
  )
  assert_true(f.without_supersets_of(Family::unit(4)).is_empty())
}
