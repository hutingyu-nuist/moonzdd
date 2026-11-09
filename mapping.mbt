///|
/// Keep selected item IDs in every member; IDs are not renumbered.
pub fn Family::project(
  self : Family,
  keep : Array[Int32],
  limits~ : Limits = Limits::default(),
) -> Family raise ZddError {
  check_set(self.universe, keep)
  let selected = Array::make(self.universe, false)
  for item in keep {
    selected[item] = true
  }
  let e = engine(self.universe, limits)
  let root = e.load(self)
  let cache : Map[Int32, Int32] = Map([])
  let unions = Map([])
  fn visit(id : Int32) -> Int32 raise ZddError {
    e.tick()
    if id <= 1 {
      return id
    }
    if cache.get(id) is Some(found) {
      return found
    }
    let node = e.nodes[id]
    let low = visit(node.low)
    let high = visit(node.high)
    let out = if selected[node.variable] {
      e.make(node.variable, low, high)
    } else {
      e.union_nodes(low, high, unions)
    }
    cache[id] = out
    out
  }
  e.finish(visit(root))
}

///|
/// Apply an arbitrary permutation. Rebuilds variable order rather than relabeling nodes.
pub fn Family::rename(
  self : Family,
  permutation : Array[Int32],
  limits~ : Limits = Limits::default(),
) -> Family raise ZddError {
  if permutation.length() != self.universe {
    raise Invalid("permutation length must equal universe")
  }
  let seen = Array::make(self.universe, false)
  for target in permutation {
    check_item(self.universe, target)
    if seen[target] {
      raise Invalid("permutation must be bijective")
    }
    seen[target] = true
  }
  let e = engine(self.universe, limits)
  let root = e.load(self)
  let cache : Map[Int32, Int32] = Map([])
  let unions = Map([])
  let products = Map([])
  fn visit(id : Int32) -> Int32 raise ZddError {
    e.tick()
    if id <= 1 {
      return id
    }
    if cache.get(id) is Some(found) {
      return found
    }
    let node = e.nodes[id]
    let low = visit(node.low)
    let high = visit(node.high)
    let item = e.make(permutation[node.variable], 0, 1)
    let with_item = e.product_nodes(item, high, false, products, unions)
    let out = e.union_nodes(low, with_item, unions)
    cache[id] = out
    out
  }
  e.finish(visit(root))
}
