///|
fn checked_count_add(a : UInt64, b : UInt64) -> UInt64 raise ZddError {
  let out = a + b
  if out < a {
    raise CountOverflow
  }
  out
}

///|
fn Family::counts(self : Family) -> Array[UInt64] raise ZddError {
  let counts : Array[UInt64] = [0, 1]
  for id in 2..<self.nodes.length() {
    let node = self.nodes[id]
    counts.push(checked_count_add(counts[node.low], counts[node.high]))
  }
  counts
}

///|
/// Exact member count. Families with >2^64-1 members raise CountOverflow.
pub fn Family::count(self : Family) -> UInt64 raise ZddError {
  self.counts()[self.root]
}

///|
pub(all) struct Enumeration {
  sets : Array[Array[Int32]]
  complete : Bool
}

///|
/// Low edges precede high edges; earlier variables are the most significant bits.
/// complete is false only if at least one actual member was omitted.
pub fn Family::enumerate(
  self : Family,
  limit : Int32,
  limits~ : Limits = Limits::default(),
) -> Enumeration raise ZddError {
  let work = engine(self.universe, limits)
  if limit < 0 || limit > 10000 {
    raise Invalid("enumeration limit must be 0..10000")
  }
  let sets : Array[Array[Int32]] = []
  let path : Array[Int32] = []
  fn visit(id : Int32) -> Bool raise ZddError {
    work.tick()
    if id == 0 {
      return true
    }
    if id == 1 {
      if sets.length() >= limit {
        return false
      }
      sets.push(path.copy())
      return true
    }
    let node = self.nodes[id]
    if !visit(node.low) {
      return false
    }
    path.push(node.variable)
    let complete = visit(node.high)
    ignore(path.pop())
    complete
  }
  let complete = visit(self.root)
  { sets, complete, }
}
