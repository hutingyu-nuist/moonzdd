// Keep members of left with no subset (including equality) in right.

///|
fn Engine::nonsupersets(
  self : Engine,
  left : Int32,
  right : Int32,
  cache : Map[(Int32, Int32), Int32],
  unions : Map[(Int32, Int32), Int32],
) -> Int32 raise ZddError {
  self.tick()
  if left == 0 || right == 1 {
    return 0
  }
  if right == 0 {
    return left
  }
  let key = (left, right)
  if cache.get(key) is Some(found) {
    return found
  }
  let variable = self.nodes[left].variable.min(self.nodes[right].variable)
  let (ll, lh) = self.split(left, variable)
  let (rl, rh) = self.split(right, variable)
  let low = self.nonsupersets(ll, rl, cache, unions)
  let choices = self.union_nodes(rl, rh, unions)
  let high = self.nonsupersets(lh, choices, cache, unions)
  let out = self.make(variable, low, high)
  cache[key] = out
  out
}

///|
pub fn Family::without_supersets_of(
  self : Family,
  other : Family,
  limits~ : Limits = Limits::default(),
) -> Family raise ZddError {
  let e = engine(self.universe, limits)
  let left = e.load(self)
  let right = e.load(other)
  e.finish(e.nonsupersets(left, right, Map([]), Map([])))
}

///|
/// Inclusion-minimal members, not merely minimum-cardinality members.
pub fn Family::minimal(
  self : Family,
  limits~ : Limits = Limits::default(),
) -> Family raise ZddError {
  let e = engine(self.universe, limits)
  let root = e.load(self)
  let cache : Map[Int32, Int32] = Map([])
  let exclusions = Map([])
  let unions = Map([])
  fn visit(id : Int32) -> Int32 raise ZddError {
    e.tick()
    if id <= 1 {
      return id
    }
    if cache.get(id) is Some(found) {
      return found
    }
    let node = e.nodes[id]
    let low = visit(node.low)
    let high = visit(node.high)
    let reduced = e.nonsupersets(high, low, exclusions, unions)
    let out = e.make(node.variable, low, reduced)
    cache[id] = out
    out
  }
  e.finish(visit(root))
}
