defmodule Chatbot.Context.Facebook.Messenger do
  alias Chatbot.Service.FacebookMessenger.ChatSession
  def validate(params),
    do: do_validate(params)

  def handle_message(params),
    do: do_handle_message(params)

  defp do_validate(params) do
    with true <- params."hub.mode" == "subscribe",
        true <- params."hub.verify_token" == Application.get_env(:chatbot, :fb_msg_verify_token) do
      {:ok, params."hub.challenge"}
    else
      _ -> {:error, :unauthorized}
    end
  end

  defp do_handle_message(params) do
    case params.object do
      "page" ->
        # FBM.send_message(%{psid: "4773592039376532", message: "testing bosskur aja"})
        response_params = build_response_params(params.entry)
        GenServer.start_link(Chatbot.Service.FacebookMessenger.Worker, response_params)
        {:ok, "EVENT_RECEIVED"}
      _ ->
        {:error, :not_found}
    end
  end

  defp build_response_params([entry]) do
    [messaging] = entry["messaging"]
    psid = messaging["sender"]["id"]

    case {ChatSession.get(psid), messaging["postback"] != nil, messaging["message"]["quick_reply"] != nil} do
      {{_, _}, true, false} ->
        %{
          psid: psid,
          type: nil,
          text: messaging["postback"]["payload"]
        }
      {{:ok, chat_data}, false, false} ->
        type = if chat_data.postback, do: chat_data.text, else: nil

        %{
          psid: psid,
          type: type,
          text: messaging["message"]["text"]
        }
      {{:ok, _}, false, true} ->
        %{
          psid: psid,
          type: "show_results",
          text: messaging["message"]["quick_reply"]["payload"]
        }
      {{:error, _}, _, _} ->
        %{
          psid: psid,
          type: nil,
          text: messaging["message"]["text"]
        }
    end
  end
end
