///|
/// Inclusion-minimal hitting sets of this family, interpreted as hyperedges.
/// Empty edge family -> {empty}; a family containing the empty edge -> empty.
/// Runs directly on compressed nodes and never enumerates the edge family.
pub fn Family::transversals(
  self : Family,
  limits~ : Limits = Limits::default(),
) -> Family raise ZddError {
  let e = engine(self.universe, limits)
  let root = e.load(self)
  let cache : Map[Int32, Int32] = Map([(0, 1), (1, 0)])
  let exclusions = Map([])
  let unions = Map([])
  fn visit(id : Int32) -> Int32 raise ZddError {
    e.tick()
    if cache.get(id) is Some(found) {
      return found
    }
    let node = e.nodes[id]
    // Without v, both residual edge families must be hit.
    let combined = e.union_nodes(node.low, node.high, unions)
    let low = visit(combined)
    // With v, all high edges are hit; only low edges remain.
    let high = visit(node.low)
    let irredundant = e.nonsupersets(high, low, exclusions, unions)
    let out = e.make(node.variable, low, irredundant)
    cache[id] = out
    out
  }
  e.finish(visit(root))
}
