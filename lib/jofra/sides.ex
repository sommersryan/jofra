defmodule Jofra.Sides do
  use GenServer

  @impl true
  def init({ home_side, visiting_side, init_batting, init_bowling }) do
    [ innings | innings_remaining ] =
      [init_batting, init_bowling, init_batting, init_bowling]
      |> Enum.zip([1,2,1,2]) #TODO: how to handle follow-ons

    state = %{}
      |> Map.put(:home, home_side)
      |> Map.put(:visitors, visiting_side)
      |> Map.put(:innings, innings)
      |> Map.put(:remaining_innings, innings_remaining)
      |> set_bowlers(init_bowling)
      |> set_batsmen(init_batting)

    { :ok, state }
  end

  defp set_bowlers(state, side) do
    bowlers = Map.get(state, side)
    |> Enum.filter(&(Map.has_key?(&1, :can_bowl)))
    |> Enum.sort_by(&(Map.get(&1, :bowling_priority) || 99), :asc)
    |> Enum.with_index()
    |> Enum.map(fn
      { bowler, idx } when idx < 2 -> Map.put(bowler, :on_spell, true)
      { bowler, _ } -> bowler
      end
    )

    state
    |> Map.put(:bowlers, bowlers)
    |> Map.put(:bowling_side, side)
  end

  defp set_batsmen(state, side) do
    { current, remaining } = Map.get(state, side) |> Enum.split(2)

    state
    |> Map.put(:batsmen, current)
    |> Map.put(:next_in, remaining)
    |> Map.put(:batting_side, side)
  end

  @impl true
  def handle_call(:state_check, _from, state) do
    { :reply, state, state }
  end

  @impl true
  def handle_call({ :wicket, _ }, _from, %{ next_in: [] } = state) do
    { :reply, :innings_break, state }
  end

  @impl true
  def handle_call({ :wicket, on_strike }, _from, state) do
    [ next_in | remaining ] = Map.get(state, :next_in)

    batsmen = case on_strike do
      true ->
        [ _ , not_out ] = state |> Map.get(:batsmen)
        [ next_in, not_out ]
      false ->
        [ not_out , _ ] = state |> Map.get(:batsmen)
        [ not_out, next_in ]
    end

    {
      :reply,
      { :ok, batsmen },
      state |> Map.put(:batsmen, batsmen) |> Map.put(:next_in, remaining)
    }
  end

  @impl true
  def handle_call({ :rotate_strike, result }, _from, state) when result in [ :single, :triple ] do
    new = state |> Map.get(:batsmen) |> Enum.reverse

    { :reply, new, state |> Map.put(:batsmen, new) }
  end

  @impl true
  def handle_call({ :rotate_strike, _ }, _from, state) do

    { :reply, Map.get(state, :batsmen), state }
  end

  @impl true
  def handle_call({ :new_over }, _from, state) do
    new_batsmen = state |> Map.get(:batsmen) |> Enum.reverse
    bowler = state |> Map.get(:bowlers) |> Enum.random #TODO bowler selection logic
    { :reply, { new_batsmen, bowler }, state
      |> Map.put(:batsmen, new_batsmen)
      |> Map.put(:bowler, bowler)}
  end

  @impl true
  def handle_call(:bowlers, _from, state) do
    { :reply, Map.get(state, :bowlers), state }
  end

  @impl true
  def handle_call(:bowler, _from, state) do
    { :reply, get_bowler(state), state }
  end

  @impl true
  def handle_call(:batsmen, _from, state) do
    { :reply, Map.get(state, :batsmen), state }
  end

  @impl true
  def handle_call(:new_innings, _from, %{ remaining_innings: [], innings: innings }) do
    { completed_innings_side, completed_innings_number } = innings

    completed_innings = %{
      side: completed_innings_side,
      innings: completed_innings_number
    }

    { :reply, { :match_complete, completed_innings }}
  end

  @impl true
  def handle_call(:new_innings, _from, state) do
    {batting_side, bowling_side} = case state.batting_side do
      :home -> { :visitors, :home }
      :visitors -> { :home, :visitors }
    end

    { completed_innings_side, completed_innings_number } = Map.get(state, :innings)
    [ new_innings | remaining_innings ] = state |> Map.get(:remaining_innings)

    state = state
    |> set_batsmen(batting_side)
    |> set_bowlers(bowling_side)
    |> Map.put(:innings, new_innings)
    |> Map.put(:remaining_innings, remaining_innings)

    completed_innings = %{
      side: completed_innings_side,
      innings: completed_innings_number
    }

    { :reply, { :ok, completed_innings, Map.get(state, :batsmen), get_bowler(state)  }, state}
  end

  @impl true
  def handle_call(:session_complete, _from, state) do
    { completed_innings_side, completed_innings_number } = Map.get(state, :innings)

    completed_innings = %{
          side: completed_innings_side,
          innings: completed_innings_number
     }

    { :reply, { :ok, completed_innings }, state }
  end

    @impl true
    def handle_cast({:over_bowled, bowler_id, timestamp}, state) do
      updated_bowlers = Map.get(state, :bowlers)
      |> Enum.map(fn
          %{ id: ^bowler_id } = bowler ->
            Map.update(bowler, :usage, [timestamp], fn x -> [ timestamp | x ] end)
            |> Map.put(:last_used, timestamp)
            |> Map.put(:previous_bowler, true)
          other -> Map.put(other, :previous_bowler, false)
      end)

      { :noreply, Map.put(state, :bowlers, updated_bowlers) }
    end

  defp get_bowler(state) do
    Map.get(state, :bowlers) |> Enum.random
  end

  def start_link(sides) do
    {:ok, _pid } = GenServer.start_link(__MODULE__, sides, name: __MODULE__)
    state = GenServer.call(__MODULE__, :state_check)
    { :ok, state }
  end

  def wicket(on_strike) do
    GenServer.call(__MODULE__, { :wicket, on_strike })
  end

  def rotate_strike(result) do
    GenServer.call(__MODULE__, { :rotate_strike, result })
  end

  def new_over() do
    GenServer.call(__MODULE__, { :new_over })
  end

  def bowlers() do
    GenServer.call(__MODULE__, :bowlers)
  end

  def bowler() do
    GenServer.call(__MODULE__, :bowler)
  end

  def batsmen() do
    GenServer.call(__MODULE__, :batsmen)
  end

  def new_innings() do
    GenServer.call(__MODULE__, :new_innings)
  end

  def over_bowled(bowler_id, timestamp) do
    GenServer.cast(__MODULE__, { :over_bowled, bowler_id, timestamp })
  end

  def session_complete() do
    GenServer.call(__MODULE__, :session_complete)
  end
end