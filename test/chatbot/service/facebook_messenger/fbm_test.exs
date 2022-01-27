defmodule Chatbot.Service.FacebookMessenger.FBMTest do
  use ExUnit.Case

  alias Chatbot.Service.FacebookMessenger.FBM

  describe "build_msg_structure/1" do
    test "when type is message" do
      params = %{
        type: "message",
        psid: "1234567890",
        message: "Chickens don't run. They build a freaking plane!"
      }

      response = FBM.build_msg_structure(params)

      assert response == %{
        recipient: %{
          id: params.psid
        },
        message: %{
          text: params.message
        }
      }
    end

    test "when type is coins_selection" do
      quick_replies = [
        %{
          content_type: "text",
          title: "BitCoins",
          payload: "bitcoin",
          image_url: "https://some-url-for-bitcoin"
        }
      ]

      params = %{
        type: "coins_selection",
        psid: "1234567890",
        quick_replies: quick_replies
      }

      response = FBM.build_msg_structure(params)

      assert response == %{
        recipient: %{
          id: params.psid
        },
        messaging_type: "RESPONSE",
        message: %{
          text: "Here are the list of coins that we found!",
          quick_replies: params.quick_replies
        }
      }
    end

    test "when type is new_session_search_selection" do
      params = %{
        type: "new_session_search_selection",
        psid: "1234567890",
        title: "Hey Chicken Little's!",
        subtitle: "Which one came first? Chicken or Egg?"
      }

      response = FBM.build_msg_structure(params)

      assert response == %{
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
