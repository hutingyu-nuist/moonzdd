// Integrator input: alternative base bundles and service bundles, indexed by item.
///|
fn main {
  try {
    let bases = @zdd.Family::from_sets(5, [[0, 2], [1, 3]])
    let services = @zdd.Family::from_sets(5, [[2], [3, 4]])
    let combined = bases.join(services)
    let incompatible = combined.containing(0).containing(3)
    let allowed = combined.difference(incompatible)
    let best = allowed.minimum_weight([3L, 1L, 2L, 3L, 5L]).unwrap()
    assert_eq(combined.count(), 4UL)
    assert_eq(allowed.count(), 3UL)
    assert_eq(best.elements, [0, 2])
    assert_eq(best.weight, 5L)
    println("configurations: combined=4 allowed=3 best=[0,2] cost=5")
  } catch {
    _ => abort("configuration integration failed")
  }
}
