///|
test "ranking skips combinatorial prefixes and inverts enumeration" {
  let f = Family::choose(9, 4)
  let all = f.enumerate(200).sets
  for i in 0..<all.length() {
    assert_eq(f.rank(all[i]), i.to_uint64())
    assert_eq(f.unrank(i.to_uint64()), all[i])
  }
  assert_eq(f.page(120UL, 3).sets, all[120:123].to_owned())
  assert_false(f.page(120UL, 3).complete)
  assert_true(f.page(126UL, 0).complete)
  assert_eq(Family::powerset(60).rank([0]), 576460752303423488UL)
  assert_true(
    try {
      ignore(f.rank([0]))
      false
    } catch {
      MissingMember => true
      _ => false
    },
  )
}
