///|
fn Engine::xor_nodes(
  self : Engine,
  left : Int32,
  right : Int32,
  cache : Map[(Int32, Int32), Int32],
) -> Int32 raise ZddError {
  self.tick()
  if left == right {
    return 0
  }
  if left == 0 {
    return right
  }
  if right == 0 {
    return left
  }
  let key = if left < right { (left, right) } else { (right, left) }
  if cache.get(key) is Some(found) {
    return found
  }
  let variable = self.nodes[left].variable.min(self.nodes[right].variable)
  let (ll, lh) = self.split(left, variable)
  let (rl, rh) = self.split(right, variable)
  let low = self.xor_nodes(ll, rl, cache)
  let high = self.xor_nodes(lh, rh, cache)
  let out = self.make(variable, low, high)
  cache[key] = out
  out
}

///|
pub fn Family::symmetric_difference(
  self : Family,
  other : Family,
  limits~ : Limits = Limits::default(),
) -> Family raise ZddError {
  let e = engine(self.universe, limits)
  let left = e.load(self)
  let right = e.load(other)
  e.finish(e.xor_nodes(left, right, Map([])))
}

///|
/// Equality is semantic, independent of construction order and node numbering.
pub fn Family::equivalent(
  self : Family,
  other : Family,
  limits~ : Limits = Limits::default(),
) -> Bool raise ZddError {
  let e = engine(self.universe, limits)
  e.load(self) == e.load(other)
}

///|
pub fn Family::is_subfamily(
  self : Family,
  other : Family,
  limits~ : Limits = Limits::default(),
) -> Bool raise ZddError {
  self.difference(other, limits~).is_empty()
}

///|
pub fn Family::is_disjoint(
  self : Family,
  other : Family,
  limits~ : Limits = Limits::default(),
) -> Bool raise ZddError {
  self.intersection(other, limits~).is_empty()
}
