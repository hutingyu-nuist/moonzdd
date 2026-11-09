///|
/// Node ID is array index + 2; children must reference earlier IDs.
pub(all) struct NodeRecord {
  variable : Int32
  low : Int32
  high : Int32
}

///|
/// Versioned, self-contained interchange. Terminals 0 and 1 are implicit.
pub(all) struct GraphData {
  format : Int32
  universe : Int32
  root : Int32
  nodes : Array[NodeRecord]
}

///|
/// Returns fresh arrays; mutating an exported graph cannot affect the Family.
pub fn Family::to_graph(self : Family) -> GraphData {
  let nodes : Array[NodeRecord] = []
  for id in 2..<self.nodes.length() {
    let node = self.nodes[id]
    nodes.push({ variable: node.variable, low: node.low, high: node.high, })
  }
  { format: 1, universe: self.universe, root: self.root, nodes, }
}

///|
/// Rejects cycles, invalid ordering, duplicate/reducible/unreachable nodes and unknown versions.
/// Does not repair malformed diagrams or retain caller-owned arrays.
pub fn Family::from_graph(
  data : GraphData,
  limits~ : Limits = Limits::default(),
) -> Family raise ZddError {
  let e = engine(data.universe, limits)
  if data.format != 1 {
    raise Invalid("unsupported graph format")
  }
  if data.nodes.length() > limits.nodes - 2 {
    raise BudgetExceeded
  }
  let size = data.nodes.length() + 2
  if data.root < 0 || data.root >= size {
    raise Invalid("invalid root ID")
  }
  for index in 0..<data.nodes.length() {
    e.tick()
    let id = index + 2
    let node = data.nodes[index]
    if node.variable < 0 || node.variable >= data.universe {
      raise Invalid("invalid variable")
    }
    if node.low < 0 || node.low >= id || node.high <= 0 || node.high >= id {
      raise Invalid("children must precede parents; high must be nonzero")
    }
    if e.nodes[node.low].variable <= node.variable ||
      e.nodes[node.high].variable <= node.variable {
      raise Invalid("variables must increase along edges")
    }
    let key = (node.variable, node.low, node.high)
    if e.unique.contains(key) {
      raise Invalid("duplicate node triple")
    }
    let made = e.make(node.variable, node.low, node.high)
    if made != id {
      raise Invalid("noncanonical node")
    }
  }
  let seen = Array::make(size, false)
  let pending = [data.root]
  let mut reachable = 0
  while pending.length() > 0 {
    e.tick()
    let id = pending.pop().unwrap()
    if id <= 1 || seen[id] {
      continue
    }
    seen[id] = true
    reachable += 1
    let node = e.nodes[id]
    pending.push(node.low)
    pending.push(node.high)
  }
  if reachable != data.nodes.length() {
    raise Invalid("unreachable nodes are forbidden")
  }
  e.finish(data.root)
}
