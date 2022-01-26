defmodule ChatbotWeb.Api.Hooks.FacebookMessengerController do
  use ChatbotWeb, :controller

  alias Chatbot.Context.Facebook.Messenger
  alias ChatbotWeb.Params.Api.Hooks.FacebookMessengers, as: Params

  require Logger

  action_fallback ChatbotWeb.FallbackController

  @doc """
    %{
      "hub.mode" => "mode?",
      "hub.verify_token" => "verify_token",
      "hub.challenge" => "12343567123"
    }
  """
  def verify_token(conn, params) do
    Logger.info("[FB_MESSENGER_CALLBACK] Verify Token #{inspect(params)}")
    with {:ok, params} <- Params.validate(:verify_token, params),
        {:ok, challenge} <- Messenger.validate(params) do
      send_resp(conn, 200, challenge)
    end
  end

  @doc """
    %{
      "object" => "...",
      "entry" => "...."
    }
  """
  def incoming_message(conn, params) do
    Logger.info("[FB_MESSENGER_CALLBACK] Incoming Message #{inspect(params)}")
    with {:ok, params} <- Params.validate(:incoming_message, params),
        {:ok, response} <- Messenger.handle_message(params) do
      Logger.info(response)
      send_resp(conn, 200, response)
    end
  end
end
