///|
test "maximal families and subset exclusions handle empty membership" {
  let f = Family::from_sets(4, [[], [0], [0, 1], [2]])
  assert_true(f.maximal().equivalent(Family::from_sets(4, [[0, 1], [2]])))
  assert_true(
    f
    .without_subsets_of(Family::singleton(4, [0, 1]))
    .equivalent(Family::singleton(4, [2])),
  )
  assert_true(
    Family::powerset(4).maximal().equivalent(Family::singleton(4, [0, 1, 2, 3])),
  )
  assert_true(Family::unit(0).maximal().contains([]))
}
