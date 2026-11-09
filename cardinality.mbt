///|
/// Keep members whose cardinality lies in the inclusive interval.
pub fn Family::cardinality(
  self : Family,
  minimum : Int32,
  maximum : Int32,
  limits~ : Limits = Limits::default(),
) -> Family raise ZddError {
  if minimum < 0 || maximum < minimum {
    raise Invalid("invalid cardinality interval")
  }
  let e = engine(self.universe, limits)
  let root = e.load(self)
  let cache : Map[(Int32, Int32, Int32), Int32] = Map([])
  fn visit(id : Int32, lo : Int32, hi : Int32) -> Int32 raise ZddError {
    e.tick()
    if id == 0 || hi < 0 {
      return 0
    }
    if id == 1 {
      return if lo == 0 { 1 } else { 0 }
    }
    let key = (id, lo, hi)
    if cache.get(key) is Some(found) {
      return found
    }
    let node = e.nodes[id]
    if lo > self.universe - node.variable {
      return 0
    }
    let low = visit(node.low, lo, hi)
    let high = visit(node.high, (lo - 1).max(0), hi - 1)
    let out = e.make(node.variable, low, high)
    cache[key] = out
    out
  }
  e.finish(visit(root, minimum, maximum.min(self.universe)))
}

///|
/// Exact count per cardinality. Intermediate storage is bounded to 2 million counters.
/// A coefficient overflow raises CountOverflow even if other coefficients fit.
pub fn Family::cardinality_spectrum(
  self : Family,
) -> Array[UInt64] raise ZddError {
  let spectra : Array[Array[UInt64]] = [[0], [1]]
  let mut stored = 2
  for id in 2..<self.nodes.length() {
    let node = self.nodes[id]
    let low = spectra[node.low]
    let high = spectra[node.high]
    let width = low.length().max(high.length() + 1)
    stored += width
    if stored > 2000000 {
      raise BudgetExceeded
    }
    let row : Array[UInt64] = Array::make(width, 0)
    for i in 0..<low.length() {
      row[i] = low[i]
    }
    for i in 0..<high.length() {
      row[i + 1] = checked_count_add(row[i + 1], high[i])
    }
    spectra.push(row)
  }
  let out : Array[UInt64] = Array::make(self.universe + 1, 0)
  let result = spectra[self.root]
  for i in 0..<result.length() {
    out[i] = result[i]
  }
  out
}
