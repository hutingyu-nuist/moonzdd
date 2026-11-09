///|
test "union preserves empty set and does not use ROBDD reduction" {
  let f = Family::from_sets(3, [[], [0], [0, 2], [0]])
  assert_true(f.contains([]))
  assert_true(f.contains([0]))
  assert_true(f.contains([0, 2]))
  assert_false(f.contains([2]))
  let p = Family::unit(1).union(Family::singleton(1, [0]))
  assert_eq(p.nodes.length(), 3)
  assert_eq(p.nodes[p.root].low, p.nodes[p.root].high)
  assert_true(p.contains([]))
  assert_true(p.contains([0]))
  assert_true(
    try {
      ignore(f.union(Family::empty(4)))
      false
    } catch {
      Invalid(_) => true
      _ => false
    },
  )
}
