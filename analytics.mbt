///|
fn checked_count_multiply(a : UInt64, b : UInt64) -> UInt64 raise ZddError {
  if a != 0UL && b > 18446744073709551615UL / a {
    raise CountOverflow
  }
  a * b
}

///|
/// Number of family members containing each item, without enumeration.
/// Forward path multiplicities account for shared suffix nodes exactly once per prefix.
pub fn Family::occurrences(self : Family) -> Array[UInt64] raise ZddError {
  let suffix = self.counts()
  let prefixes : Array[UInt64] = Array::make(self.nodes.length(), 0)
  prefixes[self.root] = 1UL
  let output : Array[UInt64] = Array::make(self.universe, 0)
  for id = self.nodes.length() - 1; id >= 2; id = id - 1 {
    let node = self.nodes[id]
    let ways = prefixes[id]
    let present = checked_count_multiply(ways, suffix[node.high])
    output[node.variable] = checked_count_add(output[node.variable], present)
    // No members terminate at 0, so no prefix count for it is needed.
    if node.low != 0 {
      prefixes[node.low] = checked_count_add(prefixes[node.low], ways)
    }
    prefixes[node.high] = checked_count_add(prefixes[node.high], ways)
  }
  output
}

///|
/// Retain every required item and exclude every forbidden item.
/// Required/forbidden lists must be sorted, unique and non-overlapping.
pub fn Family::restrict(
  self : Family,
  required : Array[Int32],
  forbidden : Array[Int32],
  limits~ : Limits = Limits::default(),
) -> Family raise ZddError {
  check_set(self.universe, required)
  check_set(self.universe, forbidden)
  for item in required {
    if forbidden.contains(item) {
      raise Invalid("contradictory item restrictions")
    }
  }
  let e = engine(self.universe, limits)
  let mut root = e.load(self)
  for item in required {
    root = e.element_nodes(root, item, 2, Map([]))
  }
  for item in forbidden {
    root = e.element_nodes(root, item, 0, Map([]))
  }
  e.finish(root)
}
