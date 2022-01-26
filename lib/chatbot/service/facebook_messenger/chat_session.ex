defmodule Chatbot.Service.FacebookMessenger.ChatSession do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [],
      name: __MODULE__
    )
  end

  @impl true
  def init(_) do
    set_protection? = if Application.get_env(:chatbot, :environment) != :test, do: :protected, else: :public

    :ets.new(:chat_sessions, [:set, set_protection?, :named_table])

    {:ok, []}
  end

  # API
  def get(psid) do
    GenServer.call(__MODULE__, {:get, psid})
  end

  def insert(psid, text, postback \\ nil) do
    GenServer.call(__MODULE__, {:insert, {psid, text, postback}})
  end

  def delete(psid) do
    GenServer.call(__MODULE__, {:delete, psid})
  end

  # CALLBACKS
  @impl true
  def handle_call({:get, psid}, _, state) do
    reply = case :ets.lookup(:chat_sessions, "chat_#{psid}") do
      [] ->
        {:error, :not_found}
      val ->
        [{_, chat_data}] = val

        expiration_time = Timex.shift(chat_data.timestamps, milliseconds: chat_data.ttl)

        is_expired? = case Timex.between?(Timex.now(), chat_data.timestamps, expiration_time) do
          true ->
            false
          _ ->
            true
        end

        if is_expired? do
          :ets.delete(:chat_sessions, "chat_#{psid}")
          {:error, :not_found}
        else
          {:ok, chat_data}
        end
    end

    {:reply, reply, state}
  end

  # Only store the message data in 5 minutes just to reset greetings message
  @impl true
  def handle_call({:insert, {psid, text, postback}}, _, state) do
    reply = case :ets.insert(:chat_sessions, {"chat_#{psid}", %{text: text, postback: postback, timestamps: Timex.now(), ttl: 300000}}) do
      true ->
        {:ok, :success}
      _ ->
        {:error, :already_exist}
    end

    {:reply, reply, state}
  end

  @impl true
  def handle_call({:delete, psid}, _, state) do
    reply = case :ets.delete(:chat_sessions, "chat_#{psid}") do
      true ->
        {:ok, :success}
      _ ->
        {:error, :failed}
    end

    {:reply, reply, state}
  end
end
