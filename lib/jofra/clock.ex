defmodule Jofra.Clock do
  defp get_duration(event) do
    durations = case event do
        :delivery -> 30..40
        :wicket -> 240..300
        :innings_break -> 480..600
        :lunch -> 2400..2400
        :tea -> 1200..1200
    end

    Enum.random(durations)
  end

  defp get_break(:morning), do: :lunch
  defp get_break(:afternoon), do: :tea
  defp get_break(:evening), do: :stumps

  defp get_next(:morning), do: :afternoon
  defp get_next(:afternoon), do: :evening
  defp get_next(:evening), do: :morning

  defp advance_by(%{ day: day, match_start_time: match_start } = match, :stumps) do
    new_time = DateTime.shift(match_start, day: day)

    match
    |> Map.put(:current_time, new_time)
    |> Map.put(:day, day + 1)
  end

  defp advance_by(%{ current_time: current_time } = match, event) do
    match
    |> Map.put(:current_time, DateTime.shift(current_time, second: get_duration(event)))
  end

  def advance(%{ innings: innings, balls: [%{ innings: last_ball_innings } | _]} = match)
  when innings > last_ball_innings do
    match
    |> advance_by(:innings_break)
  end

  def advance(%{ balls: [ %{ result: :wicket } ] } = match) do
    match
    |> advance_by(:wicket)
  end

  def advance(match) do
    match
    |> advance_by(:delivery)
  end

  def update_session(%{ over: over, balls: [ %{ over: last_ball_over } | _ ],
    current_time: current_time, session_start_time: session_start_time, session: session } = match)
    when over > last_ball_over
  do
    session_end = DateTime.shift(session_start_time, hour: 2)
    case DateTime.after?(current_time, session_end) do
      true ->
        match
        |> advance_by(get_break(session))
        |> Map.put(:session, get_next(session))
        |> set_session_start_time()
      false ->
        match
    end
  end

  def update_session(match) do
    match
  end

  def set_session_start_time(%{ current_time: current } = match) do
    match
    |> Map.put(:session_start_time, current)
  end
end