///|
/// All subsets of at least one member; an empty input family remains empty.
pub fn Family::downward_closure(
  self : Family,
  limits~ : Limits = Limits::default(),
) -> Family raise ZddError {
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
    let high = visit(node.high)
    let low = e.union_nodes(visit(node.low), high, unions)
    let out = e.make(node.variable, low, high)
    cache[id] = out
    out
  }
  e.finish(visit(root))
}

///|
/// All supersets, relative to the declared finite universe.
pub fn Family::upward_closure(
  self : Family,
  limits~ : Limits = Limits::default(),
) -> Family raise ZddError {
  let e = engine(self.universe, limits)
  let root = e.load(self)
  let cache : Map[(Int32, Int32), Int32] = Map([])
  let unions = Map([])
  fn visit(id : Int32, variable : Int32) -> Int32 raise ZddError {
    e.tick()
    if id == 0 {
      return 0
    }
    if variable == self.universe {
      return id
    }
    let key = (id, variable)
    if cache.get(key) is Some(found) {
      return found
    }
    let (left, right) = e.split(id, variable)
    let low = visit(left, variable + 1)
    let high = e.union_nodes(low, visit(right, variable + 1), unions)
    let out = e.make(variable, low, high)
    cache[key] = out
    out
  }
  e.finish(visit(root, 0))
}

///|
/// Map each member S to universe minus S. This is NOT family complement.
pub fn Family::complement_members(
  self : Family,
  limits~ : Limits = Limits::default(),
) -> Family raise ZddError {
  let e = engine(self.universe, limits)
  let root = e.load(self)
  let cache : Map[(Int32, Int32), Int32] = Map([])
  fn visit(id : Int32, variable : Int32) -> Int32 raise ZddError {
    e.tick()
    if id == 0 {
      return 0
    }
    if variable == self.universe {
      return id
    }
    let key = (id, variable)
    if cache.get(key) is Some(found) {
      return found
    }
    let (left, right) = e.split(id, variable)
    let low = visit(right, variable + 1)
    let high = visit(left, variable + 1)
    let out = e.make(variable, low, high)
    cache[key] = out
    out
  }
  e.finish(visit(root, 0))
}
