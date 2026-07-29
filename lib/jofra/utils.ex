defmodule Jofra.Utils do
  import Jofra.PlayerCreation

  def bowling_figures(match) do
    match
    |> Map.get(:balls)
    |> Enum.group_by(&{&1.innings, &1.bowler})
    |> Enum.map(fn { {innings, bowler}, balls } ->
    %{
      innings: innings,
      bowler: bowler,
      runs: Enum.sum_by(balls, fn x -> Jofra.Utils.runs_for_result(x.result) end),
      wickets: Enum.sum_by(balls, fn x -> if x.result == :wicket, do: 1, else: 0 end),
      overs: Enum.count(balls) / 6
    } |> then(&(Map.put(&1, :economy, &1.runs / &1.overs)))
    end)
  end

  def batsman_scores(match) do
    match
    |> Map.get(:balls)
    |> Enum.group_by(&{&1.innings, &1.batsman})
    |> Enum.map(fn { {innings, batsman}, balls} ->
     %{
       innings: innings,
       batsman: batsman,
       score: Enum.sum_by(balls, fn x -> Jofra.Utils.runs_for_result(x.result) end),
       balls: Enum.count(balls),
       dismissed: Enum.find(balls, fn x -> x.result == :wicket end) |> get_in([:current_time]),
       how_out: Enum.find(balls, fn x -> x.result == :wicket end) |> get_in([:wicket_type]),
       first_ball: Enum.min_by(balls, fn x -> DateTime.to_unix(x[:current_time]) end) |> get_in([:current_time])
    } end)
    |> Enum.sort_by(fn x -> x[:first_ball] end)
  end

  def write_match_summary(match) do
    %{
      batting: batsman_scores(match),
      bowling: bowling_figures(match)
    }
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
      match |> Jason.encode!(pretty: true) |> then(&File.write!("output.json", &1))
    end
end