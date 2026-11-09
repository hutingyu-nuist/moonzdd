// mode 0: intersection, mode 1: left difference.
///|
fn Engine::select_nodes(
  self : Engine,
  left : Int32,
  right : Int32,
  difference : Bool,
  cache : Map[(Int32, Int32), Int32],
) -> Int32 raise ZddError {
  self.tick()
  if left == 0 {
    return 0
  }
  if right == 0 {
    return if difference { left } else { 0 }
  }
  if left == right {
    return if difference { 0 } else { left }
  }
  let key = (left, right)
  if cache.get(key) is Some(found) {
    return found
  }
  let variable = self.nodes[left].variable.min(self.nodes[right].variable)
  let (ll, lh) = self.split(left, variable)
  let (rl, rh) = self.split(right, variable)
  let low = self.select_nodes(ll, rl, difference, cache)
  let high = self.select_nodes(lh, rh, difference, cache)
  let out = self.make(variable, low, high)
  cache[key] = out
  out
}

///|
pub fn Family::intersection(
  self : Family,
  other : Family,
  limits~ : Limits = Limits::default(),
) -> Family raise ZddError {
  let e = engine(self.universe, limits)
  let left = e.load(self)
  let right = e.load(other)
  e.finish(e.select_nodes(left, right, false, Map([])))
}

///|
pub fn Family::difference(
  self : Family,
  other : Family,
  limits~ : Limits = Limits::default(),
) -> Family raise ZddError {
  let e = engine(self.universe, limits)
  let left = e.load(self)
  let right = e.load(other)
  e.finish(e.select_nodes(left, right, true, Map([])))
}
