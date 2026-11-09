// Data-tool input: distinct baskets, projected into an analysis item domain.
///|
fn main {
  try {
    let baskets = @zdd.Family::from_sets(5, [
      [],
      [0, 2],
      [1, 2],
      [0, 1, 2],
      [2, 4],
    ])
    let projected = baskets.project([0, 1, 2])
    let imported = @zdd.Family::from_json(projected.to_json())
    assert_true(imported.equivalent(projected))
    assert_eq(imported.occurrences(), [2UL, 2UL, 4UL, 0UL, 0UL])
    let selected = imported.restrict([2], [1]).cardinality(2, 3)
    assert_eq(selected.first().unwrap(), [0, 2])
    assert_eq(selected.count(), 1UL)
    let page = imported.containing(2).page(1UL, 2)
    assert_eq(page.sets, [[1, 2], [0, 2]])
    assert_false(page.complete)
    println(
      "itemsets: projected=5 occurrences=[2,2,4,0,0] selected=[0,2] page=[[1,2],[0,2]]",
    )
  } catch {
    _ => abort("itemset integration failed")
  }
}
