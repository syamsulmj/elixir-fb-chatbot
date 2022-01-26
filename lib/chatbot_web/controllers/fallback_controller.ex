defmodule ChatbotWeb.FallbackController do
  use ChatbotWeb, :controller

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(404)
    |> put_view(ChatbotWeb.ErrorView)
    |> render("error.json", %{status: 404, error: "not found"})
  end

  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(403)
    |> put_view(ChatbotWeb.ErrorView)
    |> render("error.json", %{status: 403, error: "forbidden"})
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(401)
    |> put_view(ChatbotWeb.ErrorView)
    |> render("error.json", %{status: 401, error: "unauthorized"})
  end

  def call(conn, {:error, :bad_request}) do
    conn
    |> put_status(400)
    |> put_view(ChatbotWeb.ErrorView)
    |> render("error.json", %{status: 400, error: "bad request"})
  end

  def call(conn, {:error, :unprocessable_entity}) do
    conn
    |> put_status(422)
    |> put_view(ChatbotWeb.ErrorView)
    |> render("error.json", %{status: 422, error: "unprocessable entity"})
  end

  def call(conn, {:error, %{status: status, message: message, err_code: err_code}}) do
    conn
    |> put_status(status)
    |> put_view(ChatbotWeb.ErrorView)
    |> render("error.json", %{status: status, message: message, err_code: err_code})
  end

  def call(conn, {:error, %{status: status, message: message}}) do
    conn
    |> put_status(status)
    |> put_view(ChatbotWeb.ErrorView)
    |> render("error.json", %{status: status, error: message})
  end

  def call(conn, {:error, error}) do
    conn
    |> put_status(400)
    |> put_view(ChatbotWeb.ErrorView)
    |> render("error.json", %{error: error})
  end

  def call(conn, _any) do
    conn
    |> put_status(500)
    |> put_view(ChatbotWeb.ErrorView)
    |> render("failure.json", [])
  end
end
