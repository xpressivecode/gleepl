/// The Endpoint type represents the deepl uri to use for the translation request. As deepl offers a free and paid endpoint.
/// You will need to choose which one to use. Defaults to the free endpoint when not set.
pub type Endpoint {
  Endpoint(String)
}

/// ```gleam
/// free
/// // -> Endpoint("https://api-free.deepl.com/v2/translate")
/// ```
pub const free: Endpoint = Endpoint(
  "https://api-free.deepl.com/v2/translate",
)

/// ```gleam
/// paid
/// // -> Endpoint("https://api.deepl.com/v2/translate")
/// ```
pub const paid: Endpoint = Endpoint(
  "https://api.deepl.com/v2/translate",
)
