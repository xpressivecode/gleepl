# gleepl - A Gleam client for the [DeepL API](https://developers.deepl.com/docs/api-reference/translate)

[![Package Version](https://img.shields.io/hexpm/v/gleepl)](https://hex.pm/packages/gleepl)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/gleepl/)

## Installation

```sh
gleam add gleepl
```

## Usage

```gleam
import gleepl
import gleepl/endpoints
import gleepl/langs

gleepl.new()
|> gleepl.set_auth_key("YOUR_AUTH_KEY or from dot_env")
|> gleepl.set_endpoint(endpoints.free)
|> gleepl.set_from(langs.english)
|> gleepl.set_to(langs.french)
|> gleepl.translate("hello, friend!")

// -> Ok("Bonjour, mon ami !")
```

## Usage with [dot_env](https://hexdocs.pm/dot_env)

```gleam
import dot_env
import dot_env/env
import gleepl
import gleepl/endpoints
import gleepl/langs

dot_env.load()
let assert Ok(auth_key) = env.get("DEEPL_AUTH_KEY")

gleepl.new()
|> gleepl.set_auth_key(auth_key)
|> gleepl.set_endpoint(endpoints.free)
|> gleepl.set_from(langs.english)
|> gleepl.set_to(langs.french)
|> gleepl.translate("hello, friend!")

// -> Ok("Bonjour, mon ami !")
```

## Development

```sh
# do not forget to add your DEEPL_AUTH_KEY to .env

gleam test  # Run the tests
```
