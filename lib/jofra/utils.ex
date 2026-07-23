defmodule Jofra.Utils do
  import Jofra.PlayerCreation

  def summarize_session(session) do
    results = session
    |> Map.get(:overs)
    |> Enum.flat_map(&(&1))

    %{}
    |> Map.put(:runs, runs_in_overs(results))
    |> Map.put(:wickets, wickets_in_overs(results))
    |> Map.put(:extras,
        Enum.filter(results, &(Map.has_key?(&1, :extra)))
        |> Enum.reject(&(&1.extra == nil))
        |> Enum.frequencies_by(&(&1.extra)))
  end

  def runs_in_overs(results) do
    results
    |> Enum.filter(fn res -> Map.has_key?(res, :result) end)
    |> Enum.sum_by(fn res -> runs_for_result(res.result) end)
  end

  def wickets_in_overs(results) do
    results
    |> Enum.filter(fn res -> Map.has_key?(res, :result) end)
    |> Enum.count(fn o -> o.result == :wicket end)
  end

  def runs_for_result(result) do
    case(result) do
      :single -> 1
      :double -> 2
      :triple -> 3
      :four -> 4
      :six -> 6
      _ -> 0
    end
  end

  def build_test_side do
    []
    |> then(&([ player() |> as_batsman(:opening) | &1 ]))
    |> then(&([ player() |> as_batsman(:opening) | &1 ]))
    |> then(&([ player() |> as_batsman(:middle) | &1 ]))
    |> then(&([ player() |> as_batsman(:middle) | &1 ]))
    |> then(&([ player() |> as_batsman(:middle) | &1 ]))
    |> then(&([ player() |> as_batsman(:lower) | &1 ]))
    |> then(&([ player() |> as_batsman(:lower) |> as_bowler(:moderate) |> with_bowling_tendency(:swing) | &1 ]))
    |> then(&([ player() |> as_batsman(:lower) |> as_bowler(:moderate) |> with_bowling_tendency(:spin) | &1 ]))
    |> then(&([ player() |> as_batsman(:bowler) |> as_bowler(:great) |> with_bowling_tendency(:seam) | &1 ]))
    |> then(&([ player() |> as_batsman(:bowler) |> as_bowler(:great) |> with_bowling_tendency(:seam) | &1 ]))
    |> Enum.reverse
  end

  def test_sides do
    {
      build_test_side(),
      build_test_side(),
      :home,
      :visitors
    }
  end

    def test_day() do
      %{ sessions: sessions } = Jofra.MatchConfig.get_match_config(:test)
      start_time = ~U[2026-07-23T09:00:00Z]
      Jofra.Ball.start_link(0)
      Jofra.Clock.start_link(start_time, 2)
      sides = Jofra.Utils.test_sides
      { :ok, _ } = Jofra.Sides.start_link(sides)

      Jofra.Match.play_day([], sessions, start_time, %{ ball_age: 0, day: 1})
    end

    def test_write_session(session) do
      session |> Jason.encode! |> then(&File.write!("output.json", &1))
    end

    def test_kill_gens() do
      GenServer.stop(Jofra.Ball)
      GenServer.stop(Jofra.Clock)
      GenServer.stop(Jofra.Sides)
    end
end