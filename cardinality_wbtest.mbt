///|
test "cardinality DP agrees with binomial spectrum" {
  let f = Family::powerset(5)
  assert_eq(f.cardinality_spectrum(), [1UL, 5UL, 10UL, 10UL, 5UL, 1UL])
  assert_true(f.cardinality(2, 2).equivalent(Family::choose(5, 2)))
  assert_eq(f.cardinality(2, 4).count(), 25UL)
  assert_true(f.cardinality(6, 8).is_empty())
  assert_eq(Family::empty(0).cardinality_spectrum(), [0UL])
  assert_eq(Family::unit(0).cardinality_spectrum(), [1UL])
}
