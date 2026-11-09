///|
test "statistics and DOT work even when count overflows" {
  let f = Family::powerset(80)
  let stats = f.statistics()
  assert_eq(stats.nonterminal_nodes, 80)
  assert_eq(stats.height, 80)
  assert_eq(stats.edges, 160)
  assert_eq(stats.support.length(), 80)
  assert_true(f.to_dot().contains("style=dashed"))
  assert_true(
    try {
      ignore(f.to_dot(max_nodes=79))
      false
    } catch {
      BudgetExceeded => true
      _ => false
    },
  )
  let small = Family::singleton(5, [1, 4]).statistics()
  assert_eq(small.support, [1, 4])
  assert_eq(Family::unit(0).statistics().height, 0)
}
