import dot_env
import dot_env/env
import entrypoint

pub fn main() {
  dot_env.load()

  case env.get("DEEPL_AUTH_KEY") {
    Ok(_) -> {
      entrypoint.main()
    }
    Error(_) -> Nil
  }
}
