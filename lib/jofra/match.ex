defmodule Jofra.Match do
  import Jofra.Outcomes
  alias Jofra.{ Clock, Sides, Ball }

#  def play_match() do
#
#  end
#
  def play_day(sessions_completed, [], _, _) do
    [%{ end_time: end_time } | _ ] = sessions_completed
    %{ end_time: end_time, sessions: sessions_completed |> Enum.reverse }
  end

  def play_day(sessions_completed, sessions_to_play, current_time, context) do
    [ %{ break: break, hours: hours } | remaining_sessions ] = sessions_to_play
    :ok = Clock.new_session(current_time, hours)
    batsmen = Sides.batsmen()
    bowler = Sides.bowler()

    completed_session = play_session([], batsmen, bowler, current_time, [], context)
    { new_time } = Clock.advance(break)
    play_day([completed_session | sessions_completed], remaining_sessions, new_time, context)
  end

  def play_session(overs, batsmen, bowler, current_time, innings, context) do
    with { :ok } <- Clock.session_check()
    do
      case play_over([], batsmen, bowler, context) do
        { :ok, over, new_time, new_context} ->
          Sides.over_bowled(bowler.id, current_time)
          { :ok, ball_age, new_ball_available } = Ball.over_bowled()
          { new_batsmen, new_bowler } = Sides.new_over()
          new_context = Map.merge(new_context, %{ ball_age: ball_age, new_ball_available: new_ball_available })
          play_session([ over | overs ], new_batsmen, new_bowler, new_time, innings, new_context)

        { :innings_break, over } ->
          case Sides.new_innings() do
            { :match_complete, completed_innings } ->
              completed_overs = [ over | overs ] |> Enum.reverse
              session_innings = [ Map.put(completed_innings, :overs, completed_overs) | innings ] |> Enum.reverse
              { new_time } = Clock.advance(:delivery)

              %{ overs: completed_overs, innings: session_innings, end_time: new_time }

            { :ok, completed_innings, new_batsmen, new_bowler } ->
              { new_time } = Clock.advance(:innings_break)
              completed_innings = Map.put(completed_innings, :overs, [ over | overs ] |> Enum.reverse)
              session_innings = [ completed_innings | innings ]

              play_session([], new_batsmen, new_bowler, new_time, session_innings, Map.merge(context, %{ ball_age: 0 }))
          end
      end
    else { :session_ended } ->
      completed_overs = overs |> Enum.reverse
      { :ok, current_innings } = Sides.session_complete()
      session_innings = [ Map.put(current_innings, :overs, completed_overs) | innings ] |> Enum.reverse
      { end_time } = Clock.advance(:delivery)
      %{ overs: completed_overs, innings: session_innings, end_time: end_time }
    end
 end

  def play_over(over, batsmen, bowler, context) do
    outcome = build_outcome(batsmen, bowler, context)

    case process_outcome(outcome, context) do
      { :ok, new_batsmen, new_time, new_context } ->
        if final_ball?(over) do
          { :ok, [ outcome | over ] |> Enum.reverse, new_time, new_context }
        else
          play_over([ outcome | over ], new_batsmen, bowler, new_context)
        end
      { :innings_break } ->
        { :innings_break, [ outcome | over ] |> Enum.reverse }
    end
  end

  #TODO: must check for victory in below overloads
  def process_outcome(%{ result: :wicket, wicket_type: type }, context) do
    non_striker = type == :run_out && Enum.random([true, false])
    case Sides.wicket(!non_striker) do
      { :ok, new_batsmen } ->
        { new_time } = Clock.advance(:wicket)
        { :ok, new_batsmen, new_time, context }
      :innings_break -> { :innings_break }
    end
  end

  def process_outcome(%{ result: result, timestamp_end: new_time }, context) do
    new_batsmen = Sides.rotate_strike(result)
    { :ok, new_batsmen, new_time, context }
  end

  def final_ball?(over) do
    over
    |> Enum.reject(&(&1[:illegal_delivery] == true))
    |> Enum.count
    |> then(&(&1 == 5))
  end
end