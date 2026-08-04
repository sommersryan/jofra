defmodule Jofra.Scores do
  alias Jofra.Sides

  def update_scores(%{
      balls: [ %{ result: result } = last_ball | prev_balls ],
      scores: [ %{ runs: runs, wickets: wickets } = current_scores | previous ],
      partnership: partnership } = match) do

    result_runs = Jofra.Utils.runs_for_result(result)

    new_score =  case result do
      :wicket -> Map.put(current_scores, :wickets, wickets + 1)
      _ -> Map.put(current_scores, :runs, runs + result_runs)
    end

    new_partnership = partnership + result_runs

    updated_balls = [ last_ball |> Map.put(:scores, new_score) |> Map.put(:partnership, new_partnership) | prev_balls ]
    new_scores = [ new_score | previous ]

    match
    |> Map.put(:scores, new_scores)
    |> Map.put(:balls, updated_balls)
    |> Map.put(:partnership, partnership + result_runs)
    |> add_difference()
  end

  def update_scores(match) do
    match
  end

  def add_difference(%{ scores: scores, toss_winners: toss_winner, toss_choice: toss_choice } = match) do
    starting_side = case toss_choice do
      :bat -> toss_winner
      :bowl -> Sides.other_side(toss_winner)
    end

    match
    |> Map.put(:difference, Enum.sum_by(scores, fn x -> case x.side do
        ^starting_side -> x.runs
        _ -> -(x.runs)
      end
    end
    ))
  end

  def check_victory(%{ difference: difference, innings: 4 } = match) when difference < 0 do
    match
    |> Map.put(:complete, true)
  end

  def check_victory(match) do
    match
  end
end