import gleam/dynamic.{type Dynamic}
import gleam/http.{Post}
import gleam/http/request
import gleam/httpc
import gleam/json.{array, object, string}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleepl/endpoints
import gleepl/langs.{type Language}

/// Initializes a new  translation request
pub fn new() -> TranslationRequest {
  TranslationRequest(
    auth_key: None,
    endpoint: Some(endpoints.free),
    from: None,
    to: None,
    text: None,
  )
}

/// Sets the auth key for the request
///
/// ### Example
///
/// ```gleam
/// gleepl.new()
/// |> gleepl.set_auth_key("<your-auth-key>")
/// ```
pub fn set_auth_key(
  request: TranslationRequest,
  auth_key: String,
) -> TranslationRequest {
  TranslationRequest(..request, auth_key: Some(auth_key))
}

/// Sets the endpoint for the request as deepl offers both free and paid endpoints. Defaults to free if not set.
///
/// ### Examples
///
/// ```gleam
/// import gleepl/endpoints
///
/// gleepl.new()
/// |> gleepl.set_endpoint(endpoints.free)
/// ```
///
/// ```gleam
/// import gleepl/endpoints
///
/// gleepl.new()
/// |> gleepl.set_endpoint(endpoints.paid)
/// ```
pub fn set_endpoint(
  request: TranslationRequest,
  endpoint: endpoints.Endpoint,
) -> TranslationRequest {
  TranslationRequest(..request, endpoint: Some(endpoint))
}

/// Sets the language to translate from (deepl source language)
///
/// ### Examples
///
/// ```gleam
/// import gleepl/langs
///
/// gleepl.new()
/// |> gleepl.set_from(langs.english)
/// ```
///
/// ```gleam
/// import gleepl/langs
/// 
/// gleepl.new()
/// |> gleepl.set_from(langs.from_iso("es"))
/// ```
pub fn set_from(
  request: TranslationRequest,
  language: Language,
) -> TranslationRequest {
  TranslationRequest(..request, from: Some(language))
}

/// Sets the language to translate to (deepl target language)
///
/// ### Examples
///
/// ```gleam
/// import gleepl/langs
///
/// gleepl.new()
/// |> gleepl.set_to(langs.french)
/// ```
///
/// ```gleam
/// import gleepl/langs
/// 
/// gleepl.new()
/// |> gleepl.set_to(langs.from_iso("es"))
/// ```
pub fn set_to(
  request: TranslationRequest,
  language: Language,
) -> TranslationRequest {
  TranslationRequest(..request, to: Some(language))
}

/// Sets the text to translate
///
/// ### Example
///
/// ```gleam
/// gleepl.new()
/// |> gleepl.set_text("hello, friend!")
/// ```
pub fn set_text(request: TranslationRequest, text: String) -> TranslationRequest {
  TranslationRequest(..request, text: Some(text))
}

/// Executes the request and returns the translated text
///
/// ### Example
///
/// ```gleam
/// import gleepl/endpoints
/// import gleepl/langs
///
/// gleepl.new()
/// |> gleepl.set_auth_key("<your-auth-key>")
/// |> gleepl.set_endpoint(endpoints.free)
/// |> gleepl.set_from(langs.english)
/// |> gleepl.set_to(langs.french)
/// |> gleepl.set_text("hello, friend!")
/// |> gleepl.translate
///
/// // -> Ok("Bonjour, mon ami !")
pub fn translate(request: TranslationRequest) -> Result(String, Dynamic) {
  case validate_request(request) {
    Ok(_) -> exec_request(request)
    Error(e) -> Error(dynamic.from(e))
  }
}

fn validate_request(
  request: TranslationRequest,
) -> Result(TranslationRequest, String) {
  case request {
    TranslationRequest(None, _, _, _, _) -> Error("API auth key not set")
    TranslationRequest(_, None, _, _, _) -> Error("Endpoint not set")
    TranslationRequest(_, _, None, _, _) -> Error("From language not set")
    TranslationRequest(_, _, _, None, _) -> Error("To language not set")
    TranslationRequest(_, _, _, _, None) -> Error("Text not set")
    TranslationRequest(_, _, from, to, _) if from == to ->
      Error("From and to languages cannot be the same")
    _ -> Ok(request)
  }
}

fn request_to_json(request: TranslationRequest) -> String {
  let assert Some(langs.Language(from)) = request.from
  let assert Some(langs.Language(to)) = request.to
  let assert Some(text) = request.text

  object([
    #("text", array([text], of: string)),
    #("source_lang", string(from)),
    #("target_lang", string(to)),
  ])
  |> json.to_string
}

fn pluck_translation(json: String) -> Result(String, Dynamic) {
  let inner_decoder =
    dynamic.decode2(
      Translation,
      dynamic.field("detected_source_language", dynamic.string),
      dynamic.field("text", dynamic.string),
    )

  let outer_decoder =
    dynamic.decode1(
      DeeplResponse,
      dynamic.field("translations", dynamic.list(inner_decoder)),
    )

  case json.decode(from: json, using: outer_decoder) {
    Ok(DeeplResponse(translations)) -> {
      case list.first(translations) {
        Ok(translation) -> Ok(translation.text)
        Error(_) -> Error(dynamic.from("No translations found"))
      }
    }
    Error(_) -> Error(dynamic.from("Failed to decodde response: " <> json))
  }
}

fn exec_request(
  translation_request: TranslationRequest,
) -> Result(String, Dynamic) {
  let assert Some(auth_key) = translation_request.auth_key
  let assert Some(endpoints.Endpoint(endpoint)) = translation_request.endpoint
  let assert Ok(request) = request.to(endpoint)
  let payload = request_to_json(translation_request)

  let request =
    request.Request(
      ..request,
      headers: [
        #("content-type", "application/json"),
        #("Authorization", "Deepl-Auth-Key " <> auth_key),
      ],
    )
  let request =
    request
    |> request.set_method(Post)
    |> request.set_body(payload)

  case
    httpc.configure()
    // TODO: supresses warning, remove in future
    |> httpc.verify_tls(False)
    |> httpc.dispatch(request)
  {
    Ok(resp) -> {
      case resp.status {
        200 -> pluck_translation(resp.body)
        _ -> Error(dynamic.from(resp.body))
      }
    }
    Error(err) -> Error(err)
  }
}

type DeeplResponse {
  DeeplResponse(translations: List(Translation))
}

type Translation {
  Translation(detected_source_language: String, text: String)
}

pub type TranslationRequest {
  TranslationRequest(
    auth_key: Option(String),
    endpoint: Option(endpoints.Endpoint),
    from: Option(Language),
    to: Option(Language),
    text: Option(String),
  )
}
