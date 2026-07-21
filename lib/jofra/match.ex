defmodule Jofra.Match do
  import Jofra.Outcomes
  alias Jofra.{ Clock, Sides }

  def init_match_context do
      %{
        day: 1,
        ball_age: 0,
        inning: { :home, 0 },
        over: 0
      }
  end

  def play_session(overs, context) do

  end

  def play_over(over, batsmen, bowler, current_time, context) do
    do
      outcome = build_outcome(batsmen, bowler, current_time, context)
      { new_batsmen, new_bowler, new_time, new_context } = process_outcome(outcome)

      play_over([outcome | over ], new_batsmen, new_bowler || bowler, new_time, context)
    end
  end

  #TODO: must check for victory in below overloads
  def process_outcome(%{ result: :wicket, wicket_type: type }, context) do
    non_striker = type == :run_out && Enum.random([true, false])
    case Sides.wicket(!non_striker) do

    end
    { new_time } = Clock.advance(event)
    { new_batsmen, new_bowler, new_time, context  }
  end

  def process_outcome(%{ result: result }, context) do
    { new_batsmen } = Sides.rotate_strike(result)
    { new_time } = Clock.advance(:delivery)
    { new_batsmen, nil, new_time, context }
  end

  def over_status(over) do
    case over |> Enum.reject(&(&1[:illegal_delivery] == true)) |> Enum.count do
      6 -> { :over_complete, over }
      _ -> { :over_ongoing, over }
    end
  end
end