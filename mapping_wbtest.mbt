///|
test "projection merges duplicates and rename restores canonical order" {
  let f = Family::from_sets(4, [[0, 1], [1], [2, 3]])
  assert_true(f.project([1, 3]).equivalent(Family::from_sets(4, [[1], [3]])))
  assert_true(f.project([]).equivalent(Family::unit(4)))
  assert_true(Family::empty(4).project([]).is_empty())
  let reversed = f.rename([3, 2, 1, 0])
  assert_true(reversed.equivalent(Family::from_sets(4, [[2, 3], [2], [0, 1]])))
  assert_true(reversed.rename([3, 2, 1, 0]).equivalent(f))
  assert_true(
    try {
      ignore(f.rename([0, 1, 1, 3]))
      false
    } catch {
      Invalid(_) => true
      _ => false
    },
  )
}
