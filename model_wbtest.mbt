///|
test "terminals and singleton have distinct set-family semantics" {
  let none = Family::empty(4)
  let unit = Family::unit(4)
  assert_true(none.is_empty())
  assert_false(none.contains([]))
  assert_true(unit.contains([]))
  assert_false(unit.contains([1]))
  let f = Family::singleton(4, [0, 3])
  assert_true(f.contains([0, 3]))
  assert_false(f.contains([0]))
  assert_false(f.contains([1, 3]))
  assert_eq(f.nodes.length(), 4)
}

///|
test "invalid member and exhausted construction leave inputs untouched" {
  for elements in [[2, 1], [1, 1], [-1], [4]] {
    assert_true(
      try {
        ignore(Family::singleton(4, elements))
        false
      } catch {
        Invalid(_) => true
        _ => false
      },
    )
  }
  assert_true(
    try {
      ignore(Family::singleton(4, [0, 1], limits={ nodes: 3, steps: 100, }))
      false
    } catch {
      BudgetExceeded => true
      _ => false
    },
  )
  assert_true(Family::unit(0).contains([]))
}
