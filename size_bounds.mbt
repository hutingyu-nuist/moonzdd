///|
pub(all) struct SizeBounds {
  minimum : Int32
  maximum : Int32
}

///|
/// Cardinality extrema in O(nodes), with no member count or enumeration required.
/// None denotes the empty family; {empty} has bounds [0,0].
pub fn Family::size_bounds(self : Family) -> SizeBounds? {
  let minima : Array[Int32?] = [None, Some(0)]
  let maxima : Array[Int32?] = [None, Some(0)]
  for id in 2..<self.nodes.length() {
    let node = self.nodes[id]
    let high_min = match minima[node.high] {
      Some(value) => Some(value + 1)
      None => None
    }
    let high_max = match maxima[node.high] {
      Some(value) => Some(value + 1)
      None => None
    }
    let minimum = match (minima[node.low], high_min) {
      (Some(a), Some(b)) => Some(a.min(b))
      (Some(a), None) => Some(a)
      (None, other) => other
    }
    let maximum = match (maxima[node.low], high_max) {
      (Some(a), Some(b)) => Some(a.max(b))
      (Some(a), None) => Some(a)
      (None, other) => other
    }
    minima.push(minimum)
    maxima.push(maximum)
  }
  match (minima[self.root], maxima[self.root]) {
    (Some(minimum), Some(maximum)) => Some({ minimum, maximum, })
    _ => None
  }
}
