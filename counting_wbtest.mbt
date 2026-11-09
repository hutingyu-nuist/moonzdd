///|
test "counts detect overflow and enumeration proves truncation" {
  assert_eq(Family::powerset(63).count(), 9223372036854775808UL)
  assert_true(
    try {
      ignore(Family::powerset(64).count())
      false
    } catch {
      CountOverflow => true
      _ => false
    },
  )
  let f = Family::powerset(3)
  assert_eq(f.count(), 8UL)
  assert_eq(f.enumerate(3).sets, [[], [2], [1]])
  assert_false(f.enumerate(3).complete)
  assert_true(f.enumerate(8).complete)
  assert_true(Family::empty(3).enumerate(0).complete)
  assert_false(Family::unit(3).enumerate(0).complete)
  let x = f.enumerate(8)
  x.sets[0].push(2)
  assert_true(f.contains([]))
}
