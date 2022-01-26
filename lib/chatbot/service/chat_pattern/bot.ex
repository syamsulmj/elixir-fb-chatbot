defmodule Chatbot.Service.ChatPattern.Bot do
  alias Chatbot.Service.FacebookMessenger.ChatSession
  alias Chatbot.Service.GeckoCoin.Engine, as: GCEngine

  def handle_message(text \\ "", psid, type \\ nil) do
    text
    |> String.downcase()
    |> build_response(psid, type)
  end

  defp build_response(text, psid, type) do
    case ChatSession.get(psid) do
      {:ok, _} ->
        determine_response(text, psid, type)
      {:error, _} ->
        build_greetings(text, psid)
    end
  end

  defp determine_response(text, psid, type) do
    cond do
      String.match?(text, ~r/id/) and type == nil ->
        ChatSession.insert(psid, text, true)
        %{
          type: "message",
          psid: psid,
          message: "Alright! Please type your coin id so that we can process it!"
        }
      String.match?(text, ~r/coin_name/) and type == nil ->
        ChatSession.insert(psid, text, true)
        %{
          type: "message",
          psid: psid,
          message: "Alright! Please type your coin name so that we can process it!"
        }
      type == "id" ->
        ChatSession.insert(psid, "id", true)
        handle_search_coin_by_id(text, psid)
      type == "coin_name" ->
        ChatSession.insert(psid, "coin_name", true)
        handle_search_coin_by_coin_name(text, psid)
      type == "show_results" ->
        handle_coin_market_price(text, psid)
      String.match?(text, ~r/reset/) ->
        ChatSession.delete(psid)
        build_greetings(text, psid)
      true ->
        %{
          type: "message",
          psid: psid,
          message: "Sorry, we don't understand non-cryptonians language! Type 'Reset' if you wanna restart."
        }
    end
  end

  defp build_greetings(text, psid) do
    case get_user_firstname(psid) do
      {:ok, firstname} ->
        ChatSession.insert(psid, text)
        %{
          type: "new_session_search_selection",
          psid: psid,
          title: "Hey #{firstname}! Welcome to our Crypto Bot!",
          subtitle: "Select crypto coins searching method"
        }
      {:error, _} ->
        ChatSession.insert(psid, text)
        %{
          type: "new_session_search_selection",
          psid: psid,
          title: "Hey Cryptonian! Welcome to our Crypto Bot!",
          subtitle: "Select crypto coins searching method"
        }
    end
  end

  defp handle_search_coin_by_id(coin_id, psid) do
    case GCEngine.search(coin_id) do
      {:ok, coins} ->
        quick_replies =
          coins
          |> Enum.map(fn coin ->
            %{
              content_type: "text",
              title: coin["name"],
              payload: coin["id"],
              image_url: coin["thumb"]
            }
          end)

        %{
          type: "coins_selection",
          psid: psid,
          quick_replies: quick_replies
        }
      {:error, _} ->
        %{
          type: "message",
          psid: psid,
          message: "Well... It's either my brain is damaged or you've provided the wrong id. Please try again."
        }
    end
  end

  defp handle_search_coin_by_coin_name(coin_name, psid) do
    case GCEngine.search(coin_name) do
      {:ok, []} ->
        %{
          type: "message",
          psid: psid,
          message: "We couldn't find any coins with that name. Try again."
        }
      {:ok, coins} ->
        quick_replies =
          coins
          |> Enum.map(fn coin ->
            %{
              content_type: "text",
              title: coin["name"],
              payload: coin["id"],
              image_url: coin["thumb"]
            }
          end)

        %{
          type: "coins_selection",
          psid: psid,
          quick_replies: quick_replies
        }
      {:error, _} ->
        %{
          type: "message",
          psid: psid,
          message: "Well... It's either my brain is damaged or you've provided the wrong id. Please try again."
        }
    end
  end

  defp handle_coin_market_price(coin_id, psid) do
    case GCEngine.market_chart(coin_id) do
      {:ok, %{"prices" => prices} = _} ->
        message =
          prices
          |> Enum.map(fn [date, price] ->
            date =
              Timex.from_unix(date, :millisecond)
              |> Timex.format!("{D}-{M}-{YYYY}")

            price = Float.round(price, 2)

            "Date: #{date} \n Price: $#{price} USD"
          end)
          |> Enum.join("\n\n")

          %{
            type: "message",
            psid: psid,
            message: message
          }
      {:error, _} ->
        %{
          type: "message",
          psid: psid,
          message: "Well... It's either my brain is damaged or you've provided the wrong id. Please try again."
        }
    end
  end

  defp get_user_firstname(psid) do
    HTTPoison.start()

    case HTTPoison.get("https://graph.facebook.com/#{psid}?fields=first_name&access_token=#{Application.get_env(:chatbot, :fb_page_token)}") do
      {:ok, %{status_code: status_code} = response} when status_code == 200 ->
        {:ok, Jason.decode!(response.body)["first_name"]}
      {:ok, %{status_code: status_code} = _} when status_code != 200 ->
        {:error, :not_found}
      {:error, error} ->
        {:error, error}
    end
  end
end
