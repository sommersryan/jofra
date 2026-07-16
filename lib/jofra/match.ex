defmodule Jofra.Match do
  import Jofra.Outcomes

  def build_session(overs, session_config, session_start) do
    new_clock = case Enum.at(overs, 0) do
      nil -> session_start
      val -> val
        |> Enum.at(-1)
        |> Map.get(:timestamp_end)
    end
    
    case is_completed_session?(session_start, session_config, new_clock) do
      true -> overs |> Enum.reverse()
      false ->
        over = build_over([], new_clock)
        [ over | overs ] |> build_session(session_config, session_start)
    end
  end
  
  defp is_completed_session?(session_start, session_config, match_clock) do
    session_end = session_start 
      |> DateTime.add(Map.get(session_config, :hours), :hour)
    
    DateTime.after?(match_clock, session_end)
  end

  def build_over(over, match_clock) do
    case is_completed_over?(over) do
      true -> over |> Enum.reverse()
      false ->
        outcome = build_outcome(match_clock)
        new_clock = Map.get(outcome, :timestamp_end)
        [ outcome | over ] |> build_over(new_clock)
    end
  end

  defp is_completed_over?(over) do
    over
    |> Enum.reject(fn o -> Map.get(o, :illegal_delivery) == true end)
    |> Enum.count()
    |> then(&(&1 == 6))
  end
end