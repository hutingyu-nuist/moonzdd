///|
test "JSON round trips and rejects unknown fields duplicate keys and fractional IDs" {
  let f = Family::choose(8, 4)
  let text = f.to_json()
  assert_true(Family::from_json(text).equivalent(f))
  assert_eq(Family::from_json(text).to_json(), text)
  for
    text in [
      "null", "{\"format\":1,\"format\":1,\"universe\":0,\"root\":1,\"nodes\":[]}",
      "{\"format\":1,\"universe\":0,\"root\":1.5,\"nodes\":[]}", "{\"format\":1,\"universe\":0,\"root\":1,\"nodes\":[],\"extra\":0}",
      "{\"format\":1,\"universe\":1,\"root\":2,\"nodes\":[[0,0,0]]}", "{\"format\":1,\"universe\":0,\"root\":1e99,\"nodes\":[]}",
    ] {
    assert_true(
      try {
        ignore(Family::from_json(text))
        false
      } catch {
        Invalid(_) => true
        _ => false
      },
    )
  }
}
