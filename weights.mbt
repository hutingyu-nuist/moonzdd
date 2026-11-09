///|
pub(all) struct WeightedSet {
  elements : Array[Int32]
  weight : Int64
}

///|
fn checked_weight_add(a : Int64, b : Int64) -> Int64 raise ZddError {
  if (b > 0L && a > 9223372036854775807L - b) ||
    (b < 0L && a < -9223372036854775808L - b) {
    raise WeightOverflow
  }
  a + b
}

///|
fn Family::optimize(
  self : Family,
  weights : Array[Int64],
  maximize : Bool,
) -> WeightedSet? raise ZddError {
  if weights.length() != self.universe {
    raise Invalid("one signed weight per item is required")
  }
  let scores : Array[Int64?] = [None, Some(0L)]
  let branches : Array[Bool] = [false, false]
  for id in 2..<self.nodes.length() {
    let node = self.nodes[id]
    let low = scores[node.low]
    let high = match scores[node.high] {
      None => None
      Some(score) => Some(checked_weight_add(score, weights[node.variable]))
    }
    let choose_high = match (low, high) {
      (None, Some(_)) => true
      (Some(a), Some(b)) => if maximize { b > a } else { b < a }
      _ => false
    }
    branches.push(choose_high)
    scores.push(if choose_high { high } else { low })
  }
  match scores[self.root] {
    None => None
    Some(weight) => {
      let elements : Array[Int32] = []
      let mut id = self.root
      while id > 1 {
        let node = self.nodes[id]
        if branches[id] {
          elements.push(node.variable)
          id = node.high
        } else {
          id = node.low
        }
      }
      Some({ elements, weight, })
    }
  }
}

///|
/// Additive signed Int64 costs; tie breaks in traversal order (low first).
/// Any evaluated intermediate score overflow is an explicit error.
pub fn Family::minimum_weight(
  self : Family,
  weights : Array[Int64],
) -> WeightedSet? raise ZddError {
  self.optimize(weights, false)
}

///|
pub fn Family::maximum_weight(
  self : Family,
  weights : Array[Int64],
) -> WeightedSet? raise ZddError {
  self.optimize(weights, true)
}
