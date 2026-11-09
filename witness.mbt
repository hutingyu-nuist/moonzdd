///|
fn Family::endpoint(self : Family, last : Bool) -> Array[Int32]? {
  if self.root == 0 {
    return None
  }
  let out : Array[Int32] = []
  let mut id = self.root
  while id > 1 {
    let node = self.nodes[id]
    // Every high edge is nonempty. Prefer low only when it accepts a member.
    if last || node.low == 0 {
      out.push(node.variable)
      id = node.high
    } else {
      id = node.low
    }
  }
  Some(out)
}

///|
/// First member in traversal order, including when total count overflows UInt64.
pub fn Family::first(self : Family) -> Array[Int32]? {
  self.endpoint(false)
}

///|
/// Last member in traversal order; O(universe), no counting or enumeration.
pub fn Family::last(self : Family) -> Array[Int32]? {
  self.endpoint(true)
}
