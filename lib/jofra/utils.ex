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

  def gpa(grades) do
    num = grades
    |> Enum.sum_by(fn x -> points_for_grade(x) end)

    num / Enum.count(grades)
  end

  def points_for_grade(grade) do
    case(grade) do
      :a -> 4
      :b -> 3
      :c -> 2
      :d -> 1
      _ -> 0
    end
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

  def test_match do
    home = build_test_side()
    visitors = build_test_side()
    match = Jofra.Match.init_match(home, visitors, :home, :bat)
    Jofra.Match.play_match(match)
  end

  def debug_match do
    test_match() |> then(fn _x -> nil end)
  end

    def test_write_match(match) do
      match |> Jason.encode! |> then(&File.write!("output.json", &1))
    end
end