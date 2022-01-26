defmodule Chatbot.Service.ChatPattern.BotTest do
  use ExUnit.Case

  alias Chatbot.Service.ChatPattern.Bot

  describe "handle_message/2" do
    test "test new message no firstname" do
      :ets.delete_all_objects(:chat_sessions)

      text = "hello"
      psid = "1234567890"
      type = nil

      response = Bot.handle_message(text, psid, type)

      assert response == %{
        type: "new_session_search_selection",
        psid: psid,
        title: "Hey Cryptonian! Welcome to our Crypto Bot!",
        subtitle: "Select crypto coins searching method"
      }
    end
  end
end
