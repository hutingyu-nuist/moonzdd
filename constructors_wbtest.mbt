///|
test "compressed powersets retain optional item nodes" {
  let all = Family::powerset(80)
  assert_eq(all.nodes.length(), 82)
  assert_true(all.contains([]))
  assert_true(all.contains([0, 7, 79]))
  assert_true(Family::choose(4, 2).contains([0, 3]))
  assert_false(Family::choose(4, 2).contains([0]))
  assert_true(Family::choose(4, 5).is_empty())
  assert_true(Family::choose(0, 0).contains([]))
  assert_true(Family::items(0).is_empty())
}
