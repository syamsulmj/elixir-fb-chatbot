defmodule Chatbot.Service.FacebookMessenger.ChatSessionTest do
  use ExUnit.Case, async: false

  alias Chatbot.Service.FacebookMessenger.ChatSession

  setup do
    :ets.delete_all_objects(:chat_sessions)

    :ok
  end

  test "get session" do
    psid = "123456123456"
    text = "testing"

    insert_resp = ChatSession.insert(psid, text)
    resp = ChatSession.get(psid)

    assert insert_resp == {:ok, :success}

    assert {:ok, _} = resp

    {_, data} = resp

    assert data.text == text
    assert data.postback == nil
  end

  test "insert session" do
    psid = "123456123456"
    text = "testing"

    insert_resp = ChatSession.insert(psid, text)

    assert insert_resp == {:ok, :success}
  end

  test "delete session" do
    psid = "123456123456"
    text = "testing"

    ChatSession.insert(psid, text)

    resp = ChatSession.delete(psid)

    assert resp == {:ok, :success}
  end
end
