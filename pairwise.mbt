// Set-valued intersection/difference of each operand pair. Distinct from family
// intersection/difference: those compare whole members instead of their items.
///|
fn Engine::pairwise_nodes(
  self : Engine,
  left : Int32,
  right : Int32,
  subtract : Bool,
  cache : Map[(Int32, Int32), Int32],
  unions : Map[(Int32, Int32), Int32],
) -> Int32 raise ZddError {
  self.tick()
  if left == 0 || right == 0 {
    return 0
  }
  if left == 1 {
    return 1
  }
  if right == 1 {
    return if subtract { left } else { 1 }
  }
  let key = (left, right)
  if cache.get(key) is Some(found) {
    return found
  }
  let variable = self.nodes[left].variable.min(self.nodes[right].variable)
  let (ll, lh) = self.split(left, variable)
  let (rl, rh) = self.split(right, variable)
  let neither = self.pairwise_nodes(ll, rl, subtract, cache, unions)
  let right_only = self.pairwise_nodes(ll, rh, subtract, cache, unions)
  let common_low = self.union_nodes(neither, right_only, unions)
  let both = self.pairwise_nodes(lh, rh, subtract, cache, unions)
  let left_only = self.pairwise_nodes(lh, rl, subtract, cache, unions)
  let (low, high) = if subtract {
    (self.union_nodes(common_low, both, unions), left_only)
  } else {
    (self.union_nodes(common_low, left_only, unions), both)
  }
  let out = self.make(variable, low, high)
  cache[key] = out
  out
}

///|
/// {a intersection b | a in self, b in other}; duplicates collapse.
/// Useful for capabilities shared by independently enumerated alternatives.
pub fn Family::meet(
  self : Family,
  other : Family,
  limits~ : Limits = Limits::default(),
) -> Family raise ZddError {
  let e = engine(self.universe, limits)
  let left = e.load(self)
  let right = e.load(other)
  e.finish(e.pairwise_nodes(left, right, false, Map([]), Map([])))
}

///|
/// {a minus b | a in self, b in other}; ordered, set-valued pair product.
/// Useful for residual work after alternative reusable bundles are removed.
pub fn Family::subtract_members(
  self : Family,
  other : Family,
  limits~ : Limits = Limits::default(),
) -> Family raise ZddError {
  let e = engine(self.universe, limits)
  let left = e.load(self)
  let right = e.load(other)
  e.finish(e.pairwise_nodes(left, right, true, Map([]), Map([])))
}
