defmodule Jofra.Sides do

  def build_sides(%{ toss_winners: toss_winners, toss_choice: toss_choice } = match) do
    bowling_side = case toss_choice do
      :bat -> other_side(toss_winners)
      :bowl -> toss_winners
    end

    bowlers = match
    |> Map.get(bowling_side)
    |> Enum.filter(&(&1[:can_bowl]))

    [ batsman, non_striker | next_in ] = Map.get(match, other_side(bowling_side))

    match
    |> Map.put(:bowlers, bowlers)
    |> select_bowler()
    |> Map.put(:batsmen, [ batsman, non_striker ])
    |> Map.put(:batting_side, other_side(bowling_side))
    |> Map.put(:next_in, next_in)
  end

  def other_side(:home) do
    :visitors
  end

  def other_side(:visitors) do
    :home
  end

  # TODO: bowler selection logic
  def select_bowler(%{ bowlers: bowlers, balls: [ %{ bowler: last_bowler_id } | _ ] } = match) do
    available = bowlers |> Enum.reject(fn b -> b.id == last_bowler_id end)
    Map.put(match, :bowler, Enum.random(available))
  end

  def select_bowler(%{ bowlers: bowlers } = match) do
    Map.put(match, :bowler, Enum.random(bowlers))
  end

  def new_batsman(%{ balls: [ %{ wicket_by: wicket_by } | _ ], next_in: next_in, batsmen: batsmen } = match) do
    [ next_batsman | remaining ] = next_in
    [ striker, non_striker ] = batsmen

    new_batsmen = case wicket_by do
      :batsman -> [ next_batsman, non_striker ]
      :non_striker -> [ striker, next_batsman ]
    end

    match
    |> Map.put(:next_in, remaining)
    |> Map.put(:batsmen, new_batsmen)
  end

  def new_innings(%{ innings: 4 } = match) do
    match
    |> Map.put(:complete, true)
  end

  def new_innings(%{ innings: innings, batting_side: batting_side, scores: scores } = match) do
    bowlers = match
    |> Map.get(batting_side)
    |> Enum.filter(&(&1[:can_bowl]))

    [ batsman, non_striker | next_in ] = Map.get(match, other_side(batting_side))

    match
    |> Map.put(:batting_side, other_side(batting_side))
    |> Map.put(:innings, innings + 1)
    |> Map.put(:bowlers, bowlers)
    |> select_bowler()
    |> Map.put(:batsmen, [ batsman, non_striker ])
    |> Map.put(:next_in, next_in)
    |> Map.put(:over, 0)
    |> Map.put(:scores, [ %{ side: other_side(batting_side), wickets: 0, runs: 0 } | scores ])
  end
end