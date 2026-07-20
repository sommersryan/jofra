defmodule Jofra.Sides do
  use GenServer

  @impl true
  def init({ home_side, visiting_side, init_batting, init_bowling }) do
    state = %{}
      |> Map.put(:home, home_side)
      |> Map.put(:visitors, visiting_side)
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
  def handle_call({ :wicket, _ }, _from, %{ next_in: [] } = state) do
    { :reply, :innings_break, state }
  end

  @impl true
  def handle_call({ :wicket, on_strike }, _from, state) do
    [ next_in | remaining ] = Map.get(state, :next_in)

    batsmen = case on_strike do
      true ->
        [ _ | not_out ] = state |> Map.get(:batsmen)
        [ next_in, not_out ]
      false ->
        [ not_out | _ ] = state |> Map.get(:batsmen)
        [ not_out, next_in ]
    end

    {
      :reply,
      { :wicket, batsmen },
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
    def handle_call({:change_sides}, _from, state) do
      {batting_side, bowling_side} = case state.batting_side do
        :home -> { :visitors, :home }
        :visitors -> { :home, :visitors }
      end

      state
      |> set_batsmen(batting_side)
      |> set_bowlers(bowling_side)

      { :reply, { Map.get(state, :batsmen), Map.get(state, :bowlers) |> Enum.random() },  state }
    end

  @impl true
  def handle_call(:bowlers, _from, state) do
    { :reply, Map.get(state, :bowlers), state }
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

  def start_link(sides) do
    GenServer.start_link(__MODULE__, sides, name: __MODULE__)
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

  def over_bowled(bowler_id, timestamp) do
    GenServer.cast(__MODULE__, { :over_bowled, bowler_id, timestamp })
  end

  def change_sides() do
    GenServer.cast(__MODULE__, { :change_sides })
  end
end