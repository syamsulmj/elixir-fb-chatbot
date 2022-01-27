defmodule Chatbot.Service.ChatPattern.BotTest do
  use ExUnit.Case, async: true

  alias Chatbot.Service.ChatPattern.Bot
  alias Chatbot.Service.FacebookMessenger.ChatSession

  describe "handle_message/2" do
    setup do
      :ets.delete_all_objects(:chat_sessions)

      :ok
    end

    test "test new message no firstname" do
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

    test "handle message by id when chat session exist" do
      psid = "1234567890"
      text = "id"
      type = nil

      # add chat session here
      ChatSession.insert(psid, "hello")

      response = Bot.handle_message(text, psid, type)

      assert response == %{
        type: "message",
        psid: psid,
        message: "Alright! Please type your coin id so that we can process it!"
      }
    end

    test "handle message by coin name when chat session exist" do
      psid = "1234567890"
      text = "coin_name"
      type = nil

      # add chat session here
      ChatSession.insert(psid, "hello")

      response = Bot.handle_message(text, psid, type)

      assert response == %{
        type: "message",
        psid: psid,
        message: "Alright! Please type your coin name so that we can process it!"
      }
    end

    test "handle message when type is id" do
      psid = "1234567890"
      text = "bitcoin"
      type = "id"

      ChatSession.insert(psid, "id", true)

      response = Bot.handle_message(text, psid, type)

      assert %{
        type: "coins_selection",
        psid: "1234567890",
        quick_replies: _
        } = response
    end

    test "handle message when type is coin_name" do
      psid = "1234567890"
      text = "bitcoin"
      type = "coin_name"

      ChatSession.insert(psid, "coin_name", true)

      response = Bot.handle_message(text, psid, type)

      assert %{
        type: "coins_selection",
        psid: "1234567890",
        quick_replies: _
        } = response
    end

    test "handle unknown message" do
      psid = "1234567890"
      text = "random_text"
      type = "random_text"

      ChatSession.insert(psid, "hello", nil)

      response = Bot.handle_message(text, psid, type)

      assert response == %{
        type: "message",
        psid: psid,
        message: "Sorry, we don't understand non-cryptonians language! Type 'Reset' if you wanna restart."
      }
    end

    test "handle reset" do
      psid = "1234567890"
      text = "reset"
      type = nil

      ChatSession.insert(psid, "hello", nil)

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
