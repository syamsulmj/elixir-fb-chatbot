defmodule ChatbotWeb.Params.Api.Hooks.FacebookMessengers do
  use Para

  validator :verify_token do
    required :"hub.mode", :string
    required :"hub.verify_token", :string
    required :"hub.challenge", :string
  end

  validator :incoming_message do
    required :object, :string
    required :entry, {:array, :map}
  end
end
