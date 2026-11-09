///|
/// Zero-based rank in low-before-high traversal order. A missing set raises MissingMember.
/// Requires the complete family count to fit UInt64.
pub fn Family::rank(
  self : Family,
  elements : Array[Int32],
) -> UInt64 raise ZddError {
  check_set(self.universe, elements)
  let counts = self.counts()
  let mut result = 0UL
  let mut id = self.root
  let mut pos = 0
  while id > 1 {
    let node = self.nodes[id]
    if pos < elements.length() && elements[pos] < node.variable {
      raise MissingMember
    }
    if pos < elements.length() && elements[pos] == node.variable {
      result = checked_count_add(result, counts[node.low])
      pos += 1
      id = node.high
    } else {
      id = node.low
    }
  }
  if id != 1 || pos != elements.length() {
    raise MissingMember
  }
  result
}

///|
fn Family::select_rank(
  self : Family,
  ordinal : UInt64,
  counts : Array[UInt64],
) -> Array[Int32] raise ZddError {
  if ordinal >= counts[self.root] {
    raise Invalid("rank outside family")
  }
  let out : Array[Int32] = []
  let mut remaining = ordinal
  let mut id = self.root
  while id > 1 {
    let node = self.nodes[id]
    let low_count = counts[node.low]
    if remaining < low_count {
      id = node.low
    } else {
      remaining -= low_count
      out.push(node.variable)
      id = node.high
    }
  }
  out
}

///|
pub fn Family::unrank(
  self : Family,
  ordinal : UInt64,
) -> Array[Int32] raise ZddError {
  self.select_rank(ordinal, self.counts())
}

///|
/// Skip directly to offset without enumerating earlier members.
pub fn Family::page(
  self : Family,
  offset : UInt64,
  limit : Int32,
) -> Enumeration raise ZddError {
  if limit < 0 || limit > 10000 {
    raise Invalid("page limit must be 0..10000")
  }
  let counts = self.counts()
  let total = counts[self.root]
  if offset > total {
    raise Invalid("page offset beyond family")
  }
  let sets : Array[Array[Int32]] = []
  let mut next = offset
  while next < total && sets.length() < limit {
    sets.push(self.select_rank(next, counts))
    next += 1UL
  }
  { sets, complete: next == total, }
}
