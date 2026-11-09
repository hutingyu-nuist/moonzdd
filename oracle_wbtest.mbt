// Independent truth-table oracle: each finite member is a bit mask, each family
// is an eight-bit truth table. No decision graph recursion occurs in this oracle.

///|
fn oracle_set(mask : Int32) -> Array[Int32] {
  let out : Array[Int32] = []
  for item in 0..<3 {
    if (mask & (1 << item)) != 0 {
      out.push(item)
    }
  }
  out
}

///|
fn oracle_family(table : Int32) -> Family raise ZddError {
  let sets : Array[Array[Int32]] = []
  for mask in 0..<8 {
    if (table & (1 << mask)) != 0 {
      sets.push(oracle_set(mask))
    }
  }
  Family::from_sets(3, sets)
}

///|
fn oracle_accepts(table : Int32, mask : Int32) -> Bool {
  (table & (1 << mask)) != 0
}

///|
fn oracle_assert(family : Family, table : Int32) -> Unit raise {
  let mut count = 0
  for mask in 0..<8 {
    let expected = oracle_accepts(table, mask)
    assert_eq(family.contains(oracle_set(mask)), expected)
    if expected {
      count += 1
    }
  }
  assert_eq(family.count(), count.to_uint64())
}

///|
fn oracle_binary(a : Int32, b : Int32, mode : Int32) -> Int32 {
  let mut out = 0
  for x in 0..<8 {
    if !oracle_accepts(a, x) {
      continue
    }
    for y in 0..<8 {
      if !oracle_accepts(b, y) {
        continue
      }
      let result = match mode {
        0 => x | y
        1 => if (x & y) == 0 { x | y } else { -1 }
        2 => x & y
        _ => x & (7 ^ y)
      }
      if result >= 0 {
        out = out | (1 << result)
      }
    }
  }
  out
}

///|
test "oracle all 256 families: antichains closures and transversals" {
  for table in 0..<256 {
    let family = oracle_family(table)
    let mut minimal = 0
    let mut maximal = 0
    let mut downward = 0
    let mut upward = 0
    let mut hitting = 0
    let mut complement = 0
    for x in 0..<8 {
      let mut is_minimal = oracle_accepts(table, x)
      let mut is_maximal = is_minimal
      let mut hits = true
      for y in 0..<8 {
        if !oracle_accepts(table, y) {
          continue
        }
        if x != y && (x & y) == y {
          is_minimal = false
        }
        if x != y && (x & y) == x {
          is_maximal = false
        }
        if (x & y) == x {
          downward = downward | (1 << x)
        }
        if (x & y) == y {
          upward = upward | (1 << x)
        }
        if (x & y) == 0 {
          hits = false
        }
      }
      if is_minimal {
        minimal = minimal | (1 << x)
      }
      if is_maximal {
        maximal = maximal | (1 << x)
      }
      if hits {
        hitting = hitting | (1 << x)
      }
      if oracle_accepts(table, x) {
        complement = complement | (1 << (7 ^ x))
      }
    }
    let mut minimal_hitting = hitting
    for x in 0..<8 {
      for y in 0..<8 {
        if x != y && oracle_accepts(hitting, y) && (x & y) == y {
          minimal_hitting = minimal_hitting & (255 ^ (1 << x))
        }
      }
    }
    oracle_assert(family.minimal(), minimal)
    oracle_assert(family.maximal(), maximal)
    oracle_assert(family.downward_closure(), downward)
    oracle_assert(family.upward_closure(), upward)
    oracle_assert(family.complement_members(), complement)
    oracle_assert(family.transversals(), minimal_hitting)
    assert_true(Family::from_json(family.to_json()).equivalent(family))
  }
}

///|
test "oracle 4096 family pairs: algebra products and subsumption" {
  for a in 0..<256 {
    let fa = oracle_family(a)
    for j in 0..<16 {
      let b = (j * 17 + a * 13) % 256
      let fb = oracle_family(b)
      oracle_assert(fa.union(fb), a | b)
      oracle_assert(fa.intersection(fb), a & b)
      oracle_assert(fa.difference(fb), a & (255 ^ b))
      oracle_assert(fa.symmetric_difference(fb), a ^ b)
      oracle_assert(fa.join(fb), oracle_binary(a, b, 0))
      oracle_assert(fa.disjoint_join(fb), oracle_binary(a, b, 1))
      oracle_assert(fa.meet(fb), oracle_binary(a, b, 2))
      oracle_assert(fa.subtract_members(fb), oracle_binary(a, b, 3))
      let mut nonsupersets = a
      let mut nonsubsets = a
      for x in 0..<8 {
        for y in 0..<8 {
          if !oracle_accepts(b, y) {
            continue
          }
          if (x & y) == y {
            nonsupersets = nonsupersets & (255 ^ (1 << x))
          }
          if (x & y) == x {
            nonsubsets = nonsubsets & (255 ^ (1 << x))
          }
        }
      }
      oracle_assert(fa.without_supersets_of(fb), nonsupersets)
      oracle_assert(fa.without_subsets_of(fb), nonsubsets)
      assert_eq(fa.is_subfamily(fb), (a & b) == a)
      assert_eq(fa.equivalent(fb), a == b)
      assert_eq(fa.is_disjoint(fb), (a & b) == 0)
    }
  }
}

///|
test "oracle item transforms projection rank spectra weights on every small family" {
  for table in 0..<256 {
    let f = oracle_family(table)
    for item in 0..<3 {
      let bit = 1 << item
      let mut excluded = 0
      let mut containing = 0
      let mut cofactored = 0
      let mut toggled = 0
      let mut projected = 0
      for x in 0..<8 {
        if !oracle_accepts(table, x) {
          continue
        }
        if (x & bit) == 0 {
          excluded = excluded | (1 << x)
        } else {
          containing = containing | (1 << x)
          cofactored = cofactored | (1 << (x ^ bit))
        }
        toggled = toggled | (1 << (x ^ bit))
        projected = projected | (1 << (x & bit))
      }
      oracle_assert(f.excluding(item), excluded)
      oracle_assert(f.containing(item), containing)
      oracle_assert(f.cofactor(item), cofactored)
      oracle_assert(f.toggle(item), toggled)
      oracle_assert(f.project([item]), projected)
    }
    let expected_spectrum : Array[UInt64] = [0, 0, 0, 0]
    let occurrence : Array[UInt64] = [0, 0, 0]
    let ordered : Array[Array[Int32]] = []
    let mut min_cost : Int64? = None
    let mut max_cost : Int64? = None
    for order in 0..<8 {
      let x = ((order & 1) << 2) | (order & 2) | ((order & 4) >> 2)
      if !oracle_accepts(table, x) {
        continue
      }
      let elements = oracle_set(x)
      ordered.push(elements)
      expected_spectrum[elements.length()] += 1UL
      let weights = [-3L, 0L, 5L]
      let mut cost = 0L
      for item in elements {
        occurrence[item] += 1UL
        cost += weights[item]
      }
      min_cost = Some(
        match min_cost {
          Some(old) => old.min(cost)
          None => cost
        },
      )
      max_cost = Some(
        match max_cost {
          Some(old) => old.max(cost)
          None => cost
        },
      )
    }
    assert_eq(f.cardinality_spectrum(), expected_spectrum)
    assert_eq(f.occurrences(), occurrence)
    assert_eq(f.enumerate(8).sets, ordered)
    assert_eq(f.first(), ordered.get(0))
    assert_eq(f.last(), ordered.last())
    for i in 0..<ordered.length() {
      assert_eq(f.rank(ordered[i]), i.to_uint64())
      assert_eq(f.unrank(i.to_uint64()), ordered[i])
    }
    match (f.minimum_weight([-3L, 0L, 5L]), min_cost) {
      (Some(actual), Some(expected)) => {
        assert_eq(actual.weight, expected)
        assert_true(f.contains(actual.elements))
      }
      (None, None) => ()
      _ => fail("minimum witness mismatch")
    }
    match (f.maximum_weight([-3L, 0L, 5L]), max_cost) {
      (Some(actual), Some(expected)) => {
        assert_eq(actual.weight, expected)
        assert_true(f.contains(actual.elements))
      }
      (None, None) => ()
      _ => fail("maximum witness mismatch")
    }
    for lo in 0..<4 {
      for hi in lo..<4 {
        let mut expected = 0
        for x in 0..<8 {
          let size = oracle_set(x).length()
          if oracle_accepts(table, x) && size >= lo && size <= hi {
            expected = expected | (1 << x)
          }
        }
        oracle_assert(f.cardinality(lo, hi), expected)
      }
    }
  }
}
