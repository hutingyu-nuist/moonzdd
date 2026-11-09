///|
fn check_item(universe : Int32, item : Int32) -> Unit raise ZddError {
  if item < 0 || item >= universe {
    raise Invalid("item outside universe")
  }
}

// 0 exclude, 1 take cofactor, 2 retain containing sets, 3 toggle.

///|
fn Engine::element_nodes(
  self : Engine,
  id : Int32,
  item : Int32,
  mode : Int32,
  cache : Map[Int32, Int32],
) -> Int32 raise ZddError {
  self.tick()
  if id == 0 {
    return 0
  }
  if cache.get(id) is Some(found) {
    return found
  }
  let node = self.nodes[id]
  let out = if id <= 1 || node.variable > item {
    match mode {
      0 => id
      3 => self.make(item, 0, id)
      _ => 0
    }
  } else if node.variable == item {
    match mode {
      0 => node.low
      1 => node.high
      2 => self.make(item, 0, node.high)
      _ => self.make(item, node.high, node.low)
    }
  } else {
    let low = self.element_nodes(node.low, item, mode, cache)
    let high = self.element_nodes(node.high, item, mode, cache)
    self.make(node.variable, low, high)
  }
  cache[id] = out
  out
}

///|
fn Family::element_transform(
  self : Family,
  item : Int32,
  mode : Int32,
  limits : Limits,
) -> Family raise ZddError {
  check_item(self.universe, item)
  let e = engine(self.universe, limits)
  let root = e.load(self)
  e.finish(e.element_nodes(root, item, mode, Map([])))
}

///|
pub fn Family::excluding(
  self : Family,
  item : Int32,
  limits~ : Limits = Limits::default(),
) -> Family raise ZddError {
  self.element_transform(item, 0, limits)
}

///|
/// Keep sets containing item and REMOVE that item from the returned members.
pub fn Family::cofactor(
  self : Family,
  item : Int32,
  limits~ : Limits = Limits::default(),
) -> Family raise ZddError {
  self.element_transform(item, 1, limits)
}

///|
/// Keep sets containing item without changing them.
pub fn Family::containing(
  self : Family,
  item : Int32,
  limits~ : Limits = Limits::default(),
) -> Family raise ZddError {
  self.element_transform(item, 2, limits)
}

///|
pub fn Family::toggle(
  self : Family,
  item : Int32,
  limits~ : Limits = Limits::default(),
) -> Family raise ZddError {
  self.element_transform(item, 3, limits)
}
