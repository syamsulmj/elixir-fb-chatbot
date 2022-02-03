defmodule ChatbotWeb.PageController do
  use ChatbotWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def private_confidential(conn, _params) do
    render(conn, "private_confidential.html")
  end

  def term_condition(conn, _params) do
    render(conn, "term_condition.html")
  end
end
