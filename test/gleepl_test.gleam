import envoy
import gleepl
import gleepl/endpoints
import gleepl/langs
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

// DO NOT FORGET TO SET YOUR AUTH KEY IN `init_request`
// DEFAULTS TO `DEEPL_AUTH_KEY` ENV VAR

pub fn from_en_to_fr_test() {
  init_request()
  |> gleepl.set_from(langs.english)
  |> gleepl.set_to(langs.french)
  |> gleepl.set_text("hello")
  |> gleepl.translate
  |> should.equal(Ok("Bonjour"))
}

pub fn from_fr_to_en_test() {
  init_request()
  |> gleepl.set_from(langs.french)
  |> gleepl.set_to(langs.english)
  |> gleepl.set_text("bonjour")
  |> gleepl.translate
  |> should.equal(Ok("Hello"))
}

pub fn from_en_to_de_test() {
  init_request()
  |> gleepl.set_from(langs.english)
  |> gleepl.set_to(langs.german)
  |> gleepl.set_text("hello")
  |> gleepl.translate
  |> should.equal(Ok("hallo"))
}

pub fn from_de_to_en_test() {
  init_request()
  |> gleepl.set_from(langs.german)
  |> gleepl.set_to(langs.english)
  |> gleepl.set_text("hallo")
  |> gleepl.translate
  |> should.equal(Ok("hello"))
}

pub fn from_en_to_sl_test() {
  init_request()
  |> gleepl.set_from(langs.english)
  |> gleepl.set_to(langs.slovenian)
  |> gleepl.set_text("hello")
  |> gleepl.translate
  |> should.equal(Ok("Pozdravljeni"))
}

pub fn from_sl_to_en_test() {
  init_request()
  |> gleepl.set_from(langs.slovenian)
  |> gleepl.set_to(langs.english)
  |> gleepl.set_text("zdravo")
  |> gleepl.translate
  |> should.equal(Ok("Hello"))
}

pub fn from_en_to_iso_lang_test() {
  init_request()
  |> gleepl.set_from(langs.english)
  |> gleepl.set_to(langs.from_iso("es"))
  |> gleepl.set_text("hello")
  |> gleepl.translate
  |> should.equal(Ok("hola"))
}

pub fn from_iso_lang_to_en_test() {
  init_request()
  |> gleepl.set_from(langs.from_iso("es"))
  |> gleepl.set_to(langs.english)
  |> gleepl.set_text("hola")
  |> gleepl.translate
  |> should.equal(Ok("hello"))
}

fn init_request() -> gleepl.TranslationRequest {
  let assert Ok(auth_key) = envoy.get("DEEPL_AUTH_KEY")

  gleepl.new()
  |> gleepl.set_auth_key(auth_key)
  |> gleepl.set_endpoint(endpoints.free)
}
