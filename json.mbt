///|
fn graph_integer(value : Json) -> Int32 raise ZddError {
  match value {
    Number(number, ..) => {
      if number < 0.0 || number > 2147483647.0 {
        raise Invalid("graph integer outside range")
      }
      let integer = number.to_int()
      if integer.to_double() != number {
        raise Invalid("graph integer must be integral")
      }
      integer
    }
    _ => raise Invalid("graph integer expected")
  }
}

///|
fn required_field(
  fields : Map[String, Json],
  key : String,
) -> Json raise ZddError {
  match fields.get(key) {
    Some(value) => value
    None => raise Invalid("missing graph field: " + key)
  }
}

///|
/// Strict four-field JSON object, nodes are [variable,low,high] triples.
/// Duplicate/unknown keys, nonintegral IDs and excessive nesting are rejected.
pub fn Family::from_json(
  text : String,
  limits~ : Limits = Limits::default(),
) -> Family raise ZddError {
  // Validate budgets before parsing; input text is bounded independently of node count.
  ignore(engine(0, limits))
  if text.length() > 4000000 {
    raise BudgetExceeded
  }
  let document = @json.parse(
    text[:],
    max_nesting_depth=8,
    reject_duplicate_keys=true,
  ) catch {
    _ => raise Invalid("invalid graph JSON")
  }
  let fields = match document {
    Object(fields) => fields
    _ => raise Invalid("graph JSON must be an object")
  }
  if fields.length() != 4 {
    raise Invalid("exactly format, universe, root, nodes are required")
  }
  let format = graph_integer(required_field(fields, "format"))
  let universe = graph_integer(required_field(fields, "universe"))
  let root = graph_integer(required_field(fields, "root"))
  let rows = match required_field(fields, "nodes") {
    Array(rows) => rows
    _ => raise Invalid("nodes must be an array")
  }
  if rows.length() > limits.nodes - 2 {
    raise BudgetExceeded
  }
  let nodes : Array[NodeRecord] = []
  for row in rows {
    match row {
      Array(values) => {
        if values.length() != 3 {
          raise Invalid("node must be an integer triple")
        }
        let variable = graph_integer(values[0])
        let low = graph_integer(values[1])
        let high = graph_integer(values[2])
        nodes.push({ variable, low, high, })
      }
      _ => raise Invalid("node must be an array")
    }
  }
  Family::from_graph({ format, universe, root, nodes, }, limits~)
}

///|
/// Deterministic JSON, contains no external references or executable expressions.
pub fn Family::to_json(self : Family) -> String {
  let output = StringBuilder()
  output.write_string(
    "{\"format\":1,\"universe\":\{self.universe},\"root\":\{self.root},\"nodes\":[",
  )
  for id in 2..<self.nodes.length() {
    if id != 2 {
      output.write_string(",")
    }
    let node = self.nodes[id]
    output.write_string("[\{node.variable},\{node.low},\{node.high}]")
  }
  output.write_string("]}")
  output.to_string()
}
