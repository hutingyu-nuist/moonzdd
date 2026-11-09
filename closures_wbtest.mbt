///|
test "closures and member complements obey finite universe duality" {
  let f = Family::from_sets(4, [[0, 1], [2]])
  assert_eq(f.downward_closure().count(), 5UL)
  assert_eq(f.upward_closure().count(), 10UL)
  assert_true(f.complement_members().complement_members().equivalent(f))
  assert_true(
    f
    .downward_closure()
    .complement_members()
    .equivalent(f.complement_members().upward_closure()),
  )
  assert_true(
    f
    .maximal()
    .complement_members()
    .equivalent(f.complement_members().minimal()),
  )
  assert_true(Family::empty(4).upward_closure().is_empty())
}
