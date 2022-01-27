defmodule Chatbot.Service.FacebookMessenger.FBM do
  alias Chatbot.Service.FacebookMessenger.Client

  @spec send_message(map()) :: {:ok, :success | :error, map()}
  def send_message(params) do
    body = build_msg_structure(params)

    case Client.request(:post, "messages", body) do
      {:ok, %{status_code: status_code} = _} when status_code == 200 ->

        {:ok, :success}
      {:ok, %{status_code: status_code} = response} when status_code != 200 ->
        {:error, response.body["error"]}
      {:error, error} ->
        {:error, error}
    end
  end

  def build_msg_structure(params) do
    case params.type do
      "message" ->
        %{
          recipient: %{
            id: params.psid
          },
          message: %{
            text: params.message
          }
        }
      "coins_selection" ->
        %{
          recipient: %{
            id: params.psid
          },
          messaging_type: "RESPONSE",
          message: %{
            text: "Here are the list of coins that we found!",
            quick_replies: params.quick_replies
          }
        }
      "new_session_search_selection" ->
        %{
          recipient: %{
            id: params.psid
          },
          message: %{
            attachment: %{
              type: "template",
              payload: %{
                template_type: "generic",
                elements: [
                  %{
                    title: params.title,
                    subtitle: params.subtitle,
                    buttons: [
                      %{
                        type: "postback",
                        title: "By ID",
                        payload: "id"
                      },
                      %{
                        type: "postback",
                        title: "By Coin Name",
                        payload: "coin_name"
                      }
                    ]
                  }
                ]
              }
            }
          }
        }
    end
  end
end
