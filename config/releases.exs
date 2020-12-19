# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

auth_username =
  System.get_env("AUTH_USERNAME") ||
  raise """
  environment variable AUTH_USERNAME is missing.
  It is required to access dashboard.
  """

auth_password =
  System.get_env("AUTH_PASSWORD") ||
  raise """
  environment variable AUTH_PASSWORD is missing.
  It is required to access dashboard.
  """

host = System.get_env("URL_HOST") || "localhost"

scheme = System.get_env("SCHEME") || "http"


config :planning_poker, PlanningPokerWeb.Endpoint,
  url: [host: host, scheme: scheme],
  http: [
    port: String.to_integer(System.get_env("PORT") || "4000"),
    compress: true,
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base: secret_key_base

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
#     config :planning_poker, PlanningPokerWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.

config :planning_poker, :basic_auth, username: auth_username, password: auth_password
