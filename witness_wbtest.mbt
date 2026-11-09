///|
test "endpoint witnesses remain available for overflowing families" {
  let huge = Family::powerset(256)
  assert_eq(huge.first().unwrap(), [])
  assert_eq(huge.last().unwrap(), Array::makei(256, i => i))
  assert_true(Family::empty(2).first() is None)
  let f = Family::from_sets(5, [[1], [1, 2], [4]])
  assert_eq(f.first().unwrap(), [4])
  assert_eq(f.last().unwrap(), [1, 2])
}
