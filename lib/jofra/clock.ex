defmodule Jofra.Clock do
  use GenServer

  @impl true
  def init({ start_time, duration }) do
    { :ok, init_session(start_time, duration) }
  end

  defp init_session(start_time, duration) do
    end_ = DateTime.shift(start_time, hour: duration)
    %{ session_start: start_time, current_time: start_time, session_end: end_ }
  end

  @impl true
  def handle_call({ :advance, event }, _from, %{ current_time: current } = state) do
    new_time = DateTime.shift(current, second: get_duration(event))
    { :reply, { new_time }, state |> Map.put(:current_time, new_time) }
  end

  @impl true
  def handle_call({ :new_session, start_time, duration }, _from, _state) do
    { :reply, :ok, init_session(start_time, duration) }
  end

  @impl true
  def handle_call(:current_time, _from, %{ current_time: current_time } = state) do
    { :reply, current_time, state }
  end

  @impl true
  def handle_call(:session_check, _from, %{ current_time: current, session_end: end_ } = state) do
    result = case DateTime.after?(current, end_) do
      true -> { :session_ended }
      false -> { :ok }
    end
    { :reply, result, state }
  end

  defp get_duration(event) do
    durations = case event do
        :delivery -> 30..40
        :wicket -> 240..300
        :innings_break -> 480..600
        :lunch -> 2400..2400
        :tea -> 1200..1200
    end

    Enum.random(durations)
  end

  def start_link(start_time, duration) do
    GenServer.start_link(__MODULE__, { start_time, duration }, name: __MODULE__)
  end

  def current_time() do
    GenServer.call(__MODULE__, :current_time)
  end

  def new_session(start_time, duration) do
    GenServer.call(__MODULE__, { :new_session, start_time, duration })
  end

  def advance(event) do
    GenServer.call(__MODULE__, { :advance, event })
  end

  def session_check do
    GenServer.call(__MODULE__, :session_check)
  end
end