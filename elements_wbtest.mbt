///|
test "cofactor removes its selected item while containing preserves it" {
  let f = Family::from_sets(4, [[], [0, 2], [2], [1, 3]])
  assert_true(f.cofactor(2).equivalent(Family::from_sets(4, [[], [0]])))
  assert_true(f.containing(2).equivalent(Family::from_sets(4, [[2], [0, 2]])))
  assert_true(f.excluding(2).equivalent(Family::from_sets(4, [[], [1, 3]])))
  for v in 0..<4 {
    assert_true(f.toggle(v).toggle(v).equivalent(f))
  }
  assert_true(Family::unit(4).toggle(2).contains([2]))
  assert_true(Family::unit(4).cofactor(2).is_empty())
}
