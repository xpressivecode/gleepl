//// The language constants are for convenience so that you do not have to remember the iso codes. They are not neccessary and you can use the `from_iso` function to set the language for any missing languages.
//// A list of suported languages can be found here: [deepl supported languages](https://developers.deepl.com/docs/resources/supported-languages#target-languages)

/// The language type is used to set the source and target language iso codes for deepl.
pub type Language {
  Language(String)
}

pub const english: Language = Language("en")
pub const french: Language = Language("fr")
pub const german: Language = Language("de")
pub const slovenian: Language = Language("sl")

/// Returns a language type for the iso language code without having to wait for gleepl updates.
///
///
/// [supported languages](https://developers.deepl.com/docs/resources/supported-languages#target-languages)
///
/// ### Example
///
/// ```gleam
/// from_iso("es")
/// // -> Language("es")
/// ```
pub fn from_iso(iso: String) -> Language {
  Language(iso)
}
