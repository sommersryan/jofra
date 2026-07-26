defmodule Jofra.Scores do
  alias Jofra.Sides

  def update_scores(%{ balls: [ %{ result: result } = last_ball | prev_balls ],
      scores: [ %{ runs: runs, wickets: wickets } = current_scores | previous ]} = match) do

    new_score =  case result do
      :wicket -> Map.put(current_scores, :wickets, wickets + 1)
      _ -> Map.put(current_scores, :runs, runs + Jofra.Utils.runs_for_result(result))
    end

    updated_balls = [ last_ball |> Map.put(:scores, new_score) | prev_balls ]
    new_scores = [ new_score | previous ]

    match
    |> Map.put(:scores, new_scores)
    |> Map.put(:balls, updated_balls)
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
end