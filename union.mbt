///|
fn Engine::split(self : Engine, id : Int32, variable : Int32) -> (Int32, Int32) {
  let node = self.nodes[id]
  if id > 1 && node.variable == variable {
    (node.low, node.high)
  } else {
    // A skipped item is absent, rather than a Boolean don't-care.
    (id, 0)
  }
}

///|
fn Engine::union_nodes(
  self : Engine,
  left : Int32,
  right : Int32,
  cache : Map[(Int32, Int32), Int32],
) -> Int32 raise ZddError {
  self.tick()
  if left == 0 {
    return right
  }
  if right == 0 || left == right {
    return left
  }
  let key = if left < right { (left, right) } else { (right, left) }
  if cache.get(key) is Some(found) {
    return found
  }
  let variable = self.nodes[left].variable.min(self.nodes[right].variable)
  let (ll, lh) = self.split(left, variable)
  let (rl, rh) = self.split(right, variable)
  let low = self.union_nodes(ll, rl, cache)
  let high = self.union_nodes(lh, rh, cache)
  let out = self.make(variable, low, high)
  cache[key] = out
  out
}

///|
pub fn Family::union(
  self : Family,
  other : Family,
  limits~ : Limits = Limits::default(),
) -> Family raise ZddError {
  let e = engine(self.universe, limits)
  let left = e.load(self)
  let right = e.load(other)
  e.finish(e.union_nodes(left, right, Map([])))
}

///|
/// Duplicate members collapse; each input member must already be sorted and unique.
pub fn Family::from_sets(
  universe : Int32,
  members : Array[Array[Int32]],
  limits~ : Limits = Limits::default(),
) -> Family raise ZddError {
  let e = engine(universe, limits)
  let cache = Map([])
  let mut root = 0
  for subset in members {
    e.tick()
    check_set(universe, subset)
    let mut singleton = 1
    for i = subset.length() - 1; i >= 0; i = i - 1 {
      singleton = e.make(subset[i], 0, singleton)
    }
    root = e.union_nodes(root, singleton, cache)
  }
  e.finish(root)
}
