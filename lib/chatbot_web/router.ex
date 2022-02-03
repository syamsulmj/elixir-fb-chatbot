defmodule ChatbotWeb.Router do
  use ChatbotWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ChatbotWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/private_confidential", PageController, :private_confidential
    get "/term_condition", PageController, :term_condition
  end

  scope "/api", ChatbotWeb.Api do
    pipe_through :api

    scope "/hooks", Hooks do
      get "/facebook-messenger", FacebookMessengerController, :verify_token
      post "/facebook-messenger", FacebookMessengerController, :incoming_message
    end
  end

  scope "/test", ChatbotWeb do
    pipe_through :api

    post "/fallback_test", TestController, :fallback_test
  end

  # Other scopes may use custom stacks.
  # scope "/api", ChatbotWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: ChatbotWeb.Telemetry
    end
  end
end
