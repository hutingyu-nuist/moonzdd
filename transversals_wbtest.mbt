///|
test "hypergraph transversals return complete minimal coverage bundles" {
  let edges = Family::from_sets(4, [[0, 1], [1, 2], [2, 3]])
  let expected = Family::from_sets(4, [[0, 2], [1, 2], [1, 3]])
  let hits = edges.transversals()
  assert_true(hits.equivalent(expected))
  assert_true(hits.transversals().equivalent(edges.minimal()))
  assert_true(Family::empty(4).transversals().equivalent(Family::unit(4)))
  assert_true(edges.union(Family::unit(4)).transversals().is_empty())
  assert_true(
    Family::items(100).transversals().contains(Array::makei(100, i => i)),
  )
}
