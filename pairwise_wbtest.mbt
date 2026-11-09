///|
test "set-valued products differ from member-level algebra" {
  let a = Family::from_sets(4, [[0, 1], [1, 2]])
  let b = Family::from_sets(4, [[1, 3], [2]])
  assert_true(a.intersection(b).is_empty())
  assert_true(a.meet(b).equivalent(Family::from_sets(4, [[], [1], [2]])))
  assert_true(
    a
    .subtract_members(b)
    .equivalent(Family::from_sets(4, [[0], [0, 1], [2], [1]])),
  )
  assert_true(a.meet(Family::empty(4)).is_empty())
  assert_true(a.subtract_members(Family::unit(4)).equivalent(a))
  assert_true(Family::powerset(80).size_bounds().unwrap().maximum == 80)
  assert_eq(Family::choose(80, 40).size_bounds().unwrap().minimum, 40)
  assert_true(Family::empty(0).size_bounds() is None)
}
