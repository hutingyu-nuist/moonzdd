///|
test "weighted optima support negative costs deterministic ties and overflow" {
  let f = Family::from_sets(4, [[0, 2], [1], [3]])
  let weights = [4L, 2L, -5L, 2L]
  let low = f.minimum_weight(weights).unwrap()
  assert_eq(low.elements, [0, 2])
  assert_eq(low.weight, -1L)
  assert_eq(f.maximum_weight(weights).unwrap().elements, [3])
  assert_true(Family::empty(4).minimum_weight(weights) is None)
  assert_eq(Family::unit(0).minimum_weight([]).unwrap().weight, 0L)
  let huge = Family::singleton(2, [0, 1])
  assert_true(
    try {
      ignore(huge.minimum_weight([9223372036854775807L, 1L]))
      false
    } catch {
      WeightOverflow => true
      _ => false
    },
  )
}
