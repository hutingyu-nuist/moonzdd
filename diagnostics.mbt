///|
pub(all) struct Statistics {
  nonterminal_nodes : Int32
  edges : Int32
  height : Int32
  support : Array[Int32]
  nodes_per_variable : Array[Int32]
}

///|
/// Structural statistics do not enumerate members or require a representable count.
pub fn Family::statistics(self : Family) -> Statistics {
  let depths = [0, 0]
  let widths = Array::make(self.universe, 0)
  for id in 2..<self.nodes.length() {
    let node = self.nodes[id]
    widths[node.variable] += 1
    depths.push(1 + depths[node.low].max(depths[node.high]))
  }
  let support : Array[Int32] = []
  for variable in 0..<self.universe {
    if widths[variable] > 0 {
      support.push(variable)
    }
  }
  let nonterminal_nodes = self.nodes.length() - 2
  {
    nonterminal_nodes,
    edges: 2 * nonterminal_nodes,
    height: depths[self.root],
    support,
    nodes_per_variable: widths,
  }
}

///|
/// Diagnostic DOT. Integer-only labels are safe to render without escaping user strings.
/// Refuses oversized output instead of emitting an unlabeled partial graph.
pub fn Family::to_dot(
  self : Family,
  max_nodes~ : Int32 = 5000,
) -> String raise ZddError {
  if max_nodes < 0 || max_nodes > 100000 {
    raise Invalid("DOT budget must be 0..100000")
  }
  if self.nodes.length() - 2 > max_nodes {
    raise BudgetExceeded
  }
  let output = StringBuilder()
  output.write_string("digraph ZDD {\n  rankdir=TB;\n  entry [shape=point];\n")
  output.write_string("  entry -> n\{self.root};\n")
  output.write_string(
    "  n0 [shape=box,label=\"empty family\"];\n  n1 [shape=box,label=\"{empty set}\"];\n",
  )
  for id in 2..<self.nodes.length() {
    let node = self.nodes[id]
    output.write_string("  n\{id} [label=\"\{node.variable}\"];\n")
    output.write_string(
      "  n\{id} -> n\{node.low} [style=dashed,label=\"0\"];\n",
    )
    output.write_string("  n\{id} -> n\{node.high} [label=\"1\"];\n")
  }
  output.write_string("}\n")
  output.to_string()
}
