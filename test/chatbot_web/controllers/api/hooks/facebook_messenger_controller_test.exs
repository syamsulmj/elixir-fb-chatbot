defmodule ChatbotWeb.Api.Hooks.FacebookMessengerControllerTest do
  use ChatbotWeb.ConnCase

  test "verify facebook token", %{conn: conn} do
    # conn = get(conn, "/")
    # assert html_response(conn, 200) =~ "Welcome to Phoenix!"
    Application.put_env(:chatbot, :fb_msg_verify_token, "test_verify_token")

    params = %{
      "hub.mode" => "subscribe",
      "hub.verify_token" => "test_verify_token",
      "hub.challenge" => "1234567890"
    }

    response =
      conn
      |> get("/api/hooks/facebook-messenger", params)
      |> response(200)

    assert response == params["hub.challenge"]
  end

  test "handle incoming message", %{conn: conn} do
    params = %{
      "entry" => [
        %{
          "id" => "109888144927890",
          "messaging" => [
            %{
              "message" => %{
                "mid" => "m_wLW6zdBJnV13gLX2Rpg7HLi57_7Ug_loTQg-sMWgp3BfrAAmwasEzxqg44MElWWo5gfhZhuDddp6B8zTvDZRHQ",
                "text" => "Hello"
              },
              "recipient" => %{
                "id" => "109888144927890"
              },
              "sender" => %{
                "id" => "4773592039376532"
              },
              "timestamp" => 1643183377166
            }
          ],
          "time" => 1643183377452
        }
      ],
      object: "page"
    }

  response =
    conn
    |> post("/api/hooks/facebook-messenger", params)
    |> response(200)

  assert response == "EVENT_RECEIVED"
  end
end
