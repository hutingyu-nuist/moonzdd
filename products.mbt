///|
fn Engine::product_nodes(
  self : Engine,
  left : Int32,
  right : Int32,
  disjoint : Bool,
  cache : Map[(Int32, Int32), Int32],
  unions : Map[(Int32, Int32), Int32],
) -> Int32 raise ZddError {
  self.tick()
  if left == 0 || right == 0 {
    return 0
  }
  if left == 1 {
    return right
  }
  if right == 1 {
    return left
  }
  let key = if left < right { (left, right) } else { (right, left) }
  if cache.get(key) is Some(found) {
    return found
  }
  let variable = self.nodes[left].variable.min(self.nodes[right].variable)
  let (ll, lh) = self.split(left, variable)
  let (rl, rh) = self.split(right, variable)
  let low = self.product_nodes(ll, rl, disjoint, cache, unions)
  let first = self.product_nodes(lh, rl, disjoint, cache, unions)
  let second = self.product_nodes(ll, rh, disjoint, cache, unions)
  let mut high = self.union_nodes(first, second, unions)
  if !disjoint {
    let both = self.product_nodes(lh, rh, false, cache, unions)
    high = self.union_nodes(high, both, unions)
  }
  let out = self.make(variable, low, high)
  cache[key] = out
  out
}

///|
/// { a union b | a in self, b in other }; duplicate results collapse.
pub fn Family::join(
  self : Family,
  other : Family,
  limits~ : Limits = Limits::default(),
) -> Family raise ZddError {
  let e = engine(self.universe, limits)
  let left = e.load(self)
  let right = e.load(other)
  e.finish(e.product_nodes(left, right, false, Map([]), Map([])))
}

///|
/// Only pairs with empty intersection contribute their union.
pub fn Family::disjoint_join(
  self : Family,
  other : Family,
  limits~ : Limits = Limits::default(),
) -> Family raise ZddError {
  let e = engine(self.universe, limits)
  let left = e.load(self)
  let right = e.load(other)
  e.finish(e.product_nodes(left, right, true, Map([]), Map([])))
}
