defmodule Jofra.Sides do
  import Jofra.Bowlers

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
    |> Map.put(:bowler_usage, new_bowler_usage(bowlers))
    |> new_bowler()
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
    |> Map.put(:partnership, 0)
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
    |> Map.put(:over, 0)
    |> Map.put(:partnership, 0)
    |> Map.put(:ball_age, 0)
    |> Map.put(:batting_side, other_side(batting_side))
    |> Map.put(:innings, innings + 1)
    |> Map.put(:bowler_usage, bowlers
              |> new_bowler_usage())
    |> Map.put(:bowlers, bowlers)
    |> new_bowler()
    |> Map.put(:batsmen, [ batsman, non_striker ])
    |> Map.put(:next_in, next_in)
    |> Map.put(:scores, [ %{ side: other_side(batting_side), wickets: 0, runs: 0 } | scores ])
  end

  def declare(%{ scores: [current_score | prev ]} = match) do
    new_score = Map.put(current_score, :declared, true)

    match
    |> Map.put(:scores, [ new_score | prev ])
    |> new_innings()
  end

  def check_declaration(%{ innings: 3, follow_on: false, difference: difference } = match)
    when difference > 430
  do
    match
    |> declare()
  end

  def check_declaration(%{ innings: 3, over: over, follow_on: false, day: 5, difference: difference} = match)
    when difference > 300 and over > 5
  do
    match
    |> declare()
  end

  def check_declaration(%{ innings: 1, difference: difference } = match) when difference > 550 do
    match
    |> declare()
  end

  def check_declaration(%{ innings: 2, difference: difference } = match) when difference < -450 do
    match
    |> declare()
  end

  def check_declaration(match) do
    match
  end
end