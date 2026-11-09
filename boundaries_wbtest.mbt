///|
test "maximum universe, invalid budgets and failed operation preserve inputs" {
  let f = Family::powerset(256)
  assert_eq(f.statistics().nonterminal_nodes, 256)
  assert_eq(f.first(), Some([]))
  assert_eq(f.last().unwrap().length(), 256)
  let before = f.to_json()
  let failed = try {
    ignore(f.union(f, limits={ nodes: 2, steps: 1, }))
    false
  } catch {
    BudgetExceeded => true
    _ => false
  }
  assert_true(failed)
  assert_eq(f.to_json(), before)
  let invalid = try {
    ignore(Family::empty(0, limits={ nodes: 1, steps: 1, }))
    false
  } catch {
    Invalid(_) => true
    _ => false
  }
  assert_true(invalid)
  let invalid_universe = try {
    ignore(Family::empty(257))
    false
  } catch {
    Invalid(_) => true
    _ => false
  }
  assert_true(invalid_universe)
}

///|
test "spectrum remains meaningful when total count overflows" {
  let f = Family::powerset(64)
  let overflow = try {
    ignore(f.count())
    false
  } catch {
    CountOverflow => true
    _ => false
  }
  assert_true(overflow)
  let spectrum = f.cardinality_spectrum()
  assert_eq(spectrum.length(), 65)
  assert_eq(spectrum[0], 1UL)
  assert_eq(spectrum[32], 1832624140942590534UL)
  assert_eq(spectrum[64], 1UL)
  let bounds = f.size_bounds().unwrap()
  assert_eq(bounds.minimum, 0)
  assert_eq(bounds.maximum, 64)
}

///|
test "negative weight overflow is reported" {
  let f = Family::singleton(2, [0, 1])
  let overflow = try {
    ignore(f.minimum_weight([-9223372036854775807L, -2L]))
    false
  } catch {
    WeightOverflow => true
    _ => false
  }
  assert_true(overflow)
}
