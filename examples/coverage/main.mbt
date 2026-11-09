// Coverage input: each requirement lists tests capable of covering it.
///|
fn main {
  try {
    let requirements = @zdd.Family::from_sets(4, [[0, 1], [1, 2], [2, 3]])
    let suites = requirements.transversals()
    let cheapest = suites.minimum_weight([5L, 2L, 4L, 1L]).unwrap()
    assert_eq(suites.count(), 3UL)
    assert_eq(cheapest.elements, [1, 3])
    assert_eq(cheapest.weight, 3L)
    for suite in suites.enumerate(100).sets {
      for requirement in [[0, 1], [1, 2], [2, 3]] {
        assert_true(requirement.any(item => suite.contains(item)))
      }
    }
    println("coverage: minimal-suites=3 cheapest=[1,3] cost=3")
  } catch {
    _ => abort("coverage integration failed")
  }
}
