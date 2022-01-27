config :chatbot, ChatbotWeb.Endpoint,
  server: true,
  http: [port: {:system, "PORT"}]
  url: [host: System.get_env("APP_NAME") <> ".gigalixirapp.com", port: 443],
  cache_static_manifest: "priv/static/cache_manifest.json"
