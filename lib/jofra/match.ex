defmodule Jofra.Match do
  import Jofra.Outcomes

  def build_session(overs, context) do
    with { :session_ongoing, current_time } <- Jofra.Clock.session_check(),
         # TODO: need to somehow check her if last ball in previous over rotated strike
         # TODO: or if last ball in previous over was a wicket
         # TODO: or if last ball was innings change
         { batsmen, bowler } <- Jofra.Sides.new_over()
    do
      context = context
        |> Map.put(:batsmen, batsmen)
        |> Map.put(:bowler, bowler)

      { over, new_context } = build_over([], context)

      build_session([ over | overs ], new_context)
    else
      { :session_ended, current_time } ->
        %{
          overs: overs |> Enum.reverse,
          started: Map.get(context, :session_start),
          ended: current_time
        }
    end
  end

  def build_over(over, context) do
    with :no_wicket <- wicket_check(over |> Enum.at(0)),
         :over_ongoing <- over_check(over),
         new_batsmen <- Jofra.Sides.rotate_strike(over |> Enum.at(0) |> Map.get(:result))
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