defmodule ChatbotWeb.FallbackControllerTest do
  use ChatbotWeb.ConnCase

  test "renders not found", %{conn: conn} do
    params = %{
      "fail_test" => :not_found
    }

    response =
      conn
      |> post("/test/fallback_test", params)
      |> json_response(404)

    assert response == %{"status" => 404, "message" => "not found"}
  end

  test "renders forbidden", %{conn: conn} do
    params = %{
      "fail_test" => :forbidden
    }

    response =
      conn
      |> post("/test/fallback_test", params)
      |> json_response(403)

    assert response == %{"status" => 403, "message" => "forbidden"}
  end

  test "renders unauthorized", %{conn: conn} do
    params = %{
      "fail_test" => :unauthorized
    }

    response =
      conn
      |> post("/test/fallback_test", params)
      |> json_response(401)

    assert response == %{"status" => 401, "message" => "unauthorized"}
  end

  test "renders bad request", %{conn: conn} do
    params = %{
      "fail_test" => :bad_request
    }

    response =
      conn
      |> post("/test/fallback_test", params)
      |> json_response(400)

    assert response == %{"status" => 400, "message" => "bad request"}
  end

  test "renders unprocessable entity", %{conn: conn} do
    params = %{
      "fail_test" => :unprocessable_entity
    }

    response =
      conn
      |> post("/test/fallback_test", params)
      |> json_response(422)

    assert response == %{"status" => 422, "message" => "unprocessable entity"}
  end
end
