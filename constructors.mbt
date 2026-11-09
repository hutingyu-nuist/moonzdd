///|
/// All 2^universe subsets in O(universe) graph nodes.
pub fn Family::powerset(
  universe : Int32,
  limits~ : Limits = Limits::default(),
) -> Family raise ZddError {
  let e = engine(universe, limits)
  let mut root = 1
  for v = universe - 1; v >= 0; v = v - 1 {
    root = e.make(v, root, root)
  }
  e.finish(root)
}

///|
/// Exactly the k-element subsets. Impossible nonnegative k returns the empty family.
pub fn Family::choose(
  universe : Int32,
  k : Int32,
  limits~ : Limits = Limits::default(),
) -> Family raise ZddError {
  let e = engine(universe, limits)
  if k < 0 {
    raise Invalid("cardinality must be nonnegative")
  }
  let cache : Map[(Int32, Int32), Int32] = Map([])
  fn visit(v : Int32, needed : Int32) -> Int32 raise ZddError {
    e.tick()
    if needed == 0 {
      return 1
    }
    if needed > universe - v {
      return 0
    }
    let key = (v, needed)
    if cache.get(key) is Some(found) {
      return found
    }
    let low = visit(v + 1, needed)
    let high = visit(v + 1, needed - 1)
    let out = e.make(v, low, high)
    cache[key] = out
    out
  }
  e.finish(visit(0, k))
}

///|
/// Every singleton item in the universe (empty when the universe is empty).
pub fn Family::items(
  universe : Int32,
  limits~ : Limits = Limits::default(),
) -> Family raise ZddError {
  Family::choose(universe, 1, limits~)
}
