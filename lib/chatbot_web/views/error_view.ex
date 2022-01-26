defmodule ChatbotWeb.ErrorView do
  use ChatbotWeb, :view

  import ChatbotWeb.ErrorHelpers

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.html", _assigns) do
  #   "Internal Server Error"
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.html" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end

  def render("error.json", %{status: status, error: error, err_code: err_code}) do
    %{
      message: error,
      status: status,
      err_code: err_code
    }
  end

  def render("error.json", %{status: status, error: error}) do
    %{
      message: error,
      status: status
    }
  end

  def render("error.json", %{error: error}) do
    parse(error)
  end

  def parse(error) when is_binary(error) do
    %{message: error}
  end

  def parse(%Ecto.Changeset{} = changeset) do
    %{
      status: 400,
      message: "bad request",
      errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
    }
  end

  def parse(error), do: translate_error(error)
end
