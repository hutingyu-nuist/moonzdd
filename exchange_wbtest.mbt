///|
test "graph exchange validates before exposing an immutable family" {
  let f = Family::choose(6, 3)
  let wire = f.to_graph()
  assert_true(Family::from_graph(wire).equivalent(f))
  wire.nodes.clear()
  assert_eq(f.count(), 20UL)
  let bad : Array[GraphData] = [
    { format: 2, universe: 2, root: 0, nodes: [], },
    {
      format: 1,
      universe: 2,
      root: 2,
      nodes: [{ variable: 0, low: 0, high: 2, }],
    },
    {
      format: 1,
      universe: 2,
      root: 2,
      nodes: [{ variable: 0, low: 1, high: 0, }],
    },
    {
      format: 1,
      universe: 2,
      root: 1,
      nodes: [{ variable: 0, low: 0, high: 1, }],
    },
    {
      format: 1,
      universe: 2,
      root: 3,
      nodes: [
        { variable: 0, low: 0, high: 1, },
        { variable: 0, low: 0, high: 1, },
      ],
    },
    {
      format: 1,
      universe: 2,
      root: 3,
      nodes: [
        { variable: 0, low: 0, high: 1, },
        { variable: 1, low: 0, high: 2, },
      ],
    },
  ]
  for data in bad {
    assert_true(
      try {
        ignore(Family::from_graph(data))
        false
      } catch {
        Invalid(_) => true
        _ => false
      },
    )
  }
}
