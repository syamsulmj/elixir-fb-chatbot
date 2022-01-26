defmodule Chatbot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Chatbot.Repo,
      # Start the Telemetry supervisor
      ChatbotWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Chatbot.PubSub},
      # Start the Endpoint (http/https)
      ChatbotWeb.Endpoint,
      {Chatbot.Service.FacebookMessenger.ChatSession, []}
      # Start a worker by calling: Chatbot.Worker.start_link(arg)
      # {Chatbot.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Chatbot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ChatbotWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
