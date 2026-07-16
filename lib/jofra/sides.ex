defmodule Jofra.Sides do
  use GenServer

  @impl true
  def init({ orders, init_batting, init_bowling }) do
    state = %{}
      |> Map.put(:home, Enum.at(orders, 0))
      |> Map.put(:visitors, Enum.at(orders, 1))
      |> set_bowlers(init_bowling)
      |> set_batsmen(init_batting)

    { :ok, state }
  end

  defp set_bowlers(state, side) do
    bowlers = Map.get(state, side)
    |> Enum.filter(&(&1.can_bowl))
    |> Enum.sort_by(&(&1.bowling_priority || 99), :asc)
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
    state
    |> Map.put(:batsmen, Map.get(state, side))
    |> Map.put(:batting_side, side)
  end

  @impl true
  def handle_call(:next_batsman, _from, %{ batsmen: [] } = state) do
    { :reply, :innings_break, state }
  end

  @impl true
  def handle_call(:next_batsman, _from, state) do
    [ next_batsman | batsmen ] = Map.get(state, :batsmen)

    { :reply, next_batsman, Map.put(state, :batsmen, batsmen )}
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

  @impl true
  def handle_cast({:change_sides}, state) do
    {batting_side, bowling_side} = case state.batting_side do
      :home -> { :visitors, :home }
      :visitors -> { :home, :visitors }
    end

    state
    |> set_batsmen(batting_side)
    |> set_bowlers(bowling_side)

    { :noreply, state }
  end

  def start_link(sides) do
    GenServer.start_link(__MODULE__, sides, name: __MODULE__)
  end

  def next_batsman() do
    GenServer.call(__MODULE__, :next_batsman)
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