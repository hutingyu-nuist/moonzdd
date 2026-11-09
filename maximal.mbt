///|
fn Engine::nonsubsets(
  self : Engine,
  left : Int32,
  right : Int32,
  cache : Map[(Int32, Int32), Int32],
  unions : Map[(Int32, Int32), Int32],
) -> Int32 raise ZddError {
  self.tick()
  if left == 0 || right == 0 {
    return left
  }
  if left == 1 {
    return 0
  }
  let key = (left, right)
  if cache.get(key) is Some(found) {
    return found
  }
  let variable = self.nodes[left].variable.min(self.nodes[right].variable)
  let (ll, lh) = self.split(left, variable)
  let (rl, rh) = self.split(right, variable)
  let choices = self.union_nodes(rl, rh, unions)
  let low = self.nonsubsets(ll, choices, cache, unions)
  let high = self.nonsubsets(lh, rh, cache, unions)
  let out = self.make(variable, low, high)
  cache[key] = out
  out
}

///|
pub fn Family::without_subsets_of(
  self : Family,
  other : Family,
  limits~ : Limits = Limits::default(),
) -> Family raise ZddError {
  let e = engine(self.universe, limits)
  let left = e.load(self)
  let right = e.load(other)
  e.finish(e.nonsubsets(left, right, Map([]), Map([])))
}

///|
pub fn Family::maximal(
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
    let high = visit(node.high)
    let low = visit(node.low)
    let reduced = e.nonsubsets(low, high, exclusions, unions)
    let out = e.make(node.variable, reduced, high)
    cache[id] = out
    out
  }
  e.finish(visit(root))
}
