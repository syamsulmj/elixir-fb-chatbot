defmodule ChatbotWeb.TestController do
  @moduledoc """
    This Controller is created only for our FallbackController
    unit test purpose.
  """

  use ChatbotWeb, :controller

  action_fallback ChatbotWeb.FallbackController
  @doc """
    %{
      fail_test: :not_found || :forbidden ....
    }
  """
  def fallback_test(_conn, params) do
    {:error, params["fail_test"]}
  end
end
