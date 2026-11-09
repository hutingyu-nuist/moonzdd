///|
/// A failed operation never modifies its operands.
pub(all) suberror ZddError {
  Invalid(String)
  BudgetExceeded
  CountOverflow
  MissingMember
}

///|
/// Finite bounds apply to intermediate nodes and recursive work, not just output.
pub(all) struct Limits {
  nodes : Int32
  steps : Int32
}

///|
pub fn Limits::default() -> Limits {
  { nodes: 100000, steps: 2000000, }
}

///|
struct Node {
  variable : Int32
  low : Int32
  high : Int32
}

///|
/// Immutable family of subsets of the ordered universe [0, universe_size()).
/// Internal node IDs never escape the value or depend on a global manager.
pub struct Family {
  universe : Int32
  nodes : Array[Node]
  root : Int32
}

///|
priv struct Engine {
  universe : Int32
  nodes : Array[Node]
  unique : Map[(Int32, Int32, Int32), Int32]
  limits : Limits
  mut steps : Int32
}

///|
fn engine(universe : Int32, limits : Limits) -> Engine raise ZddError {
  if universe < 0 || universe > 256 {
    raise Invalid("universe must be in 0..256")
  }
  if limits.nodes < 2 ||
    limits.nodes > 1000000 ||
    limits.steps < 1 ||
    limits.steps > 100000000 {
    raise Invalid("limits: nodes 2..1000000, steps 1..100000000")
  }
  let terminal = { variable: universe, low: 0, high: 0, }
  { universe, nodes: [terminal, terminal], unique: Map([]), limits, steps: 0, }
}

///|
fn Engine::tick(self : Engine) -> Unit raise ZddError {
  if self.steps >= self.limits.steps {
    raise BudgetExceeded
  }
  self.steps += 1
}

///|
fn Engine::make(
  self : Engine,
  variable : Int32,
  low : Int32,
  high : Int32,
) -> Int32 raise ZddError {
  self.tick()
  // ZDD suppression. Unlike an ROBDD, low == high must remain a node.
  if high == 0 {
    return low
  }
  let key = (variable, low, high)
  if self.unique.get(key) is Some(id) {
    return id
  }
  if self.nodes.length() >= self.limits.nodes {
    raise BudgetExceeded
  }
  let id = self.nodes.length()
  self.nodes.push({ variable, low, high, })
  self.unique[key] = id
  id
}

///|
fn Engine::load(self : Engine, family : Family) -> Int32 raise ZddError {
  if self.universe != family.universe {
    raise Invalid("operands must use the same universe")
  }
  let memo : Map[Int32, Int32] = Map([(0, 0), (1, 1)])
  fn visit(id : Int32) -> Int32 raise ZddError {
    self.tick()
    if memo.get(id) is Some(found) {
      return found
    }
    let node = family.nodes[id]
    let low = visit(node.low)
    let high = visit(node.high)
    let out = self.make(node.variable, low, high)
    memo[id] = out
    out
  }
  visit(family.root)
}

///|
fn Engine::finish(self : Engine, root : Int32) -> Family raise ZddError {
  // Compact dead intermediate nodes, preserving child-before-parent order.
  let out = [self.nodes[0], self.nodes[1]]
  let memo : Map[Int32, Int32] = Map([(0, 0), (1, 1)])
  fn visit(id : Int32) -> Int32 raise ZddError {
    self.tick()
    if memo.get(id) is Some(found) {
      return found
    }
    let node = self.nodes[id]
    let low = visit(node.low)
    let high = visit(node.high)
    let fresh = out.length()
    out.push({ variable: node.variable, low, high, })
    memo[id] = fresh
    fresh
  }
  let final_root = visit(root)
  { universe: self.universe, nodes: out, root: final_root, }
}

///|
fn check_set(universe : Int32, elements : Array[Int32]) -> Unit raise ZddError {
  let mut previous = -1
  for element in elements {
    if element <= previous || element < 0 || element >= universe {
      raise Invalid(
        "a member must be strictly increasing and inside the universe",
      )
    }
    previous = element
  }
}

///|
pub fn Family::empty(
  universe : Int32,
  limits~ : Limits = Limits::default(),
) -> Family raise ZddError {
  engine(universe, limits).finish(0)
}

///|
pub fn Family::unit(
  universe : Int32,
  limits~ : Limits = Limits::default(),
) -> Family raise ZddError {
  engine(universe, limits).finish(1)
}

///|
pub fn Family::singleton(
  universe : Int32,
  elements : Array[Int32],
  limits~ : Limits = Limits::default(),
) -> Family raise ZddError {
  let e = engine(universe, limits)
  check_set(universe, elements)
  let mut root = 1
  for i = elements.length() - 1; i >= 0; i = i - 1 {
    root = e.make(elements[i], 0, root)
  }
  e.finish(root)
}

///|
pub fn Family::universe_size(self : Family) -> Int32 {
  self.universe
}

///|
pub fn Family::is_empty(self : Family) -> Bool {
  self.root == 0
}

///|
pub fn Family::contains(
  self : Family,
  elements : Array[Int32],
) -> Bool raise ZddError {
  check_set(self.universe, elements)
  let mut pos = 0
  let mut id = self.root
  while id > 1 {
    let node = self.nodes[id]
    if pos < elements.length() && elements[pos] < node.variable {
      return false
    }
    if pos < elements.length() && elements[pos] == node.variable {
      pos += 1
      id = node.high
    } else {
      id = node.low
    }
  }
  id == 1 && pos == elements.length()
}

///|
/// Return an independently compacted value under a new operation budget.
pub fn Family::compact(
  self : Family,
  limits~ : Limits = Limits::default(),
) -> Family raise ZddError {
  let e = engine(self.universe, limits)
  e.finish(e.load(self))
}
