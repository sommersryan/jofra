defmodule Jofra.Match do
  import Jofra.Outcomes

  def build_match do
    Jofra.Match.build_session([], init_match_context())
  end

  def init_match_context do
    %{
      day: 1,
      ball_age: 0,
      inning: 1,
      over: 0
    }
  end

  def build_session(overs, context) do
    with { :session_ongoing, _ } <- Jofra.Clock.session_check(),
         last_ball <- get_last_ball(overs),
         :no_wicket <- wicket_check(last_ball),
         _ <- Jofra.Sides.rotate_strike(last_ball |> then(fn x -> x[:result] end)), # feels gross
         { batsmen, bowler } <- Jofra.Sides.new_over()
    do
      context = context
        |> Map.put(:batsmen, batsmen)
        |> Map.put(:bowler, bowler)

      { over, new_context } = build_over([], context)

      build_session([ over | overs ], new_context)
    else
      { :wicket, new_batsmen } ->
        new_time = Jofra.Clock.advance(:new_batsman)
        [ prev | tail ] = overs
        context = context |> Map.put(:batsmen, new_batsmen)
        build_session([ prev ++ [%{ event: :last_ball_wicket, timestamp: new_time }] | tail ], context)
      :innings_break ->
        new_time = Jofra.Clock.advance(:innings_break)
        { new_batsmen, new_bowler } = Jofra.Sides.change_sides()
        [ prev | tail ] = overs
        context = context |> Map.put(:batsmen, new_batsmen) |> Map.put(:bowler, new_bowler)
        build_session([ prev ++ [%{ event: :last_ball_innings, timestamp: new_time }] | tail], context)
      { :session_ended, current_time } ->
        %{
          overs: overs |> Enum.reverse,
          started: Map.get(context, :session_start),
          ended: current_time
        }
    end
  end

  def get_last_ball([]) do
    nil
  end

  def get_last_ball(overs) do
    overs |> hd() |> Enum.at(-1)
  end

  def build_over(over, context) do
    with :no_wicket <- wicket_check(over |> Enum.at(0)),
         :over_ongoing <- over_check(over),
         new_batsmen <- Jofra.Sides.rotate_strike(over |> Enum.at(0) |> then(fn x -> x[:result] end))
    do
      context = Map.put(context, :batsmen, new_batsmen)
      { outcome, new_context } = build_outcome(context)
      [ outcome | over ] |> build_over(new_context)
    else
      { :wicket, new_batsmen } ->
        new_time = Jofra.Clock.advance(:new_batsman)
        context = context |> Map.put(:batsmen, new_batsmen)
        build_over([ %{ event: :new_batsman, timestamp: new_time } | over ], context)
      :innings_break ->
        new_time = Jofra.Clock.advance(:innings_break)
        { [ %{ event: :innings_end, timestamp: new_time } | over ] |> Enum.reverse(), context }
      :over_ended ->
        { over |> Enum.reverse(), context }
    end
  end

  defp wicket_check(%{ result: :wicket, wicket_type: type }) do
    non_striker = type == :run_out && Enum.random([true, false])
    Jofra.Sides.wicket(!non_striker)
  end

  defp wicket_check(_) do
    :no_wicket
  end

  defp over_check(over) do
    length = over
    |> Enum.filter(fn o -> Map.has_key?(o, :result) end)
    |> Enum.reject(fn o -> Map.get(o, :illegal_delivery) == true end)
    |> Enum.count()

    case length == 6 do
      true -> :over_ended
      false -> :over_ongoing
    end
  end
end